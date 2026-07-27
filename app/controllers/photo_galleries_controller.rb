class PhotoGalleriesController < ApplicationController
  after_action :verify_pundit_authorization
  before_action :set_photo_gallery, only: %i[ show edit update destroy ]

  def show
    authorize @photo_gallery
    @items = @photo_gallery.ordered_items.to_a
    @current_item = @items.find { |item| item.id == params[:item_id].to_i } if params[:item_id].present?
    @current_item ||= @items.first
  end

  def new
    @photo_gallery = PhotoGallery.new
    authorize @photo_gallery
    set_parent_or_parent_scope
  end

  def edit
    authorize @photo_gallery
    @items = @photo_gallery.ordered_items
  end

  def create
    @photo_gallery = PhotoGallery.new(photo_gallery_params.merge(author: current_user))
    authorize @photo_gallery

    images = uploaded_images

    gallery_valid = @photo_gallery.valid?

    validate_upload_batch_size(images)
    @photo_gallery.errors.add(:base, "Please add at least one photo.") if images.empty?

    if gallery_valid && @photo_gallery.errors.empty?
      ActiveRecord::Base.transaction do
        @photo_gallery.save!
        # No pre-existing items yet, so if nothing was explicitly selected
        # default to the first uploaded photo becoming the cover.
        cover_index = new_cover_index || 0
        create_items_for(@photo_gallery, images, starting_position: 0, cover_index: cover_index)
      end
      redirect_to redirect_path, notice: "Photo gallery was successfully created."
    else
      set_parent_or_parent_scope
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    @photo_gallery.errors.add(:base, e.message)
    set_parent_or_parent_scope
    render :new, status: :unprocessable_entity
  end

  def update
    authorize @photo_gallery

    images = uploaded_images
    validate_upload_batch_size(images)

    destroy_ids = Array(photo_gallery_update_params[:items_attributes]&.values)
      .select { |attrs| attrs['_destroy'] == '1' }
      .map { |attrs| attrs['id'].to_i }

    resulting_count = @photo_gallery.items.count - destroy_ids.size + images.size

    if resulting_count > PhotoGallery::MAX_PHOTOS_COUNT
      @photo_gallery.errors.add(:base, "A gallery can have at most #{PhotoGallery::MAX_PHOTOS_COUNT} photos.")
    elsif resulting_count.zero?
      @photo_gallery.errors.add(:base, "A gallery must have at least one photo.")
    end

    if @photo_gallery.errors.any?
      @items = @photo_gallery.ordered_items
      return render :edit, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      @photo_gallery.update!(photo_gallery_update_params)

      next_position = (@photo_gallery.items.maximum(:position) || -1) + 1
      cover_index = new_cover_index
      @photo_gallery.items.where(cover: true).update_all(cover: false) if cover_index
      create_items_for(@photo_gallery, images, starting_position: next_position, cover_index: cover_index)

      resolve_existing_cover!(@photo_gallery)
    end

    redirect_to @photo_gallery, notice: "Photo gallery was successfully updated."
  rescue ActiveRecord::RecordInvalid => e
    @photo_gallery.errors.add(:base, e.message)
    @items = @photo_gallery.ordered_items
    render :edit, status: :unprocessable_entity
  end

  def destroy
    authorize @photo_gallery

    if @photo_gallery.destroy!
      redirect_to redirect_path, notice: "Photo gallery was successfully destroyed."
    else
      redirect_to redirect_path, alert: 'Photo gallery was not destroyed. Please try again and notify administrator.'
    end
  end

  private

  def redirect_path
    @photo_gallery.parent_id ? folder_path(@photo_gallery.parent_id) : root_path
  end

  def set_parent_or_parent_scope
    if params[:parent_id]
      @parent = folder_policy_scope.find(params[:parent_id])
    else
      @folder_policy_scope = folder_policy_scope
    end
  end

  def set_photo_gallery
    @photo_gallery = PhotoGallery.find(params[:id])
  end

  def uploaded_images
    Array(params.dig(:photo_gallery, :images)).select { |file| file.respond_to?(:original_filename) }
  end

  def uploaded_descriptions
    Array(params.dig(:photo_gallery, :image_descriptions))
  end

  def validate_upload_batch_size(images)
    if images.size > PhotoGallery::MAX_UPLOAD_BATCH
      @photo_gallery.errors.add(:base, "You can upload up to #{PhotoGallery::MAX_UPLOAD_BATCH} photos at a time.")
    end
  end

  # Creates GalleryItems for the given uploaded files, pairing each file with
  # its description by index (the order the browser submits multi-file
  # inputs matches selection order). Returns the created items in the same
  # order as `images`, so the caller can resolve a "new:INDEX" cover
  # selection back to a persisted record.
  #
  # The chosen cover flag is set directly on the item's `cover` attribute
  # *before* it is created, in the same `create!` call that attaches its
  # image. Resolving the cover afterwards via a separate find+update (on a
  # different in-memory copy of the same record) was clobbering the
  # just-attached file before it got written to disk, leaving the cover
  # photo's attachment broken. Setting it upfront avoids any second
  # read/write cycle on the item that holds the pending upload.
  def create_items_for(gallery, images, starting_position:, cover_index: nil)
    descriptions = uploaded_descriptions

    images.each_with_index.map do |image, index|
      gallery.items.create!(
        image: image,
        description: descriptions[index].presence,
        position: starting_position + index,
        cover: index == cover_index
      )
    end
  end

  # cover_selection is either:
  #   - blank: no explicit choice was made
  #   - "new:<index>": index into the batch of images being uploaded in this request
  #   - "<item_id>": an existing item's id (only relevant on update)
  #
  # Returns the index (into the images array) to mark as cover among the
  # newly created items, or nil if the selection refers to an existing item
  # or there is no selection.
  def new_cover_index
    selection = params.dig(:photo_gallery, :cover_selection)
    return nil unless selection&.start_with?('new:')

    selection.split(':', 2).last.to_i
  end

  # Handles cover selections that point at an already-persisted item
  # (existing photos on update), or falls back to making sure the gallery
  # always has *some* cover once at least one item exists. Newly uploaded
  # items are covered by `create_items_for`'s `cover_index:` and must not be
  # touched again here to avoid re-triggering their attachment.
  def resolve_existing_cover!(gallery)
    selection = params.dig(:photo_gallery, :cover_selection)

    if selection.present? && !selection.start_with?('new:')
      gallery.set_cover!(selection)
    elsif !gallery.items.covers.exists?
      gallery.set_cover!(gallery.ordered_items.first&.id)
    end
  end

  def photo_gallery_params
    params.require(:photo_gallery).permit(:title, :parent_id)
  end

  def photo_gallery_update_params
    params.require(:photo_gallery).permit(:title, items_attributes: [:id, :description, :_destroy])
  end

  def folder_policy_scope
    FolderPolicy::Scope.new(current_user, Folder.all).resolve
  end
end
