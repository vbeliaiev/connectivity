class PhotoGallery < Node
  has_many :items, as: :gallery, class_name: 'GalleryItem', dependent: :destroy
  accepts_nested_attributes_for :items, allow_destroy: true

  MAX_ITEMS_COUNT = 15
  MAX_PHOTOS_COUNT = 1000
  MAX_UPLOAD_BATCH = 25

  validates :title, presence: true

  def ordered_items
    items.ordered.includes(image_attachment: :blob)
  end

  def cover_item
    loaded_items = items.loaded? ? items : ordered_items
    loaded_items.find(&:cover?) || loaded_items.min_by { |item| [item.position || Float::INFINITY, item.created_at] }
  end

  # Marks the given item (by id) as the sole cover of the gallery.
  # No-op if item_id is blank or doesn't belong to this gallery.
  def set_cover!(item_id)
    return if item_id.blank?

    item = items.find_by(id: item_id)
    return unless item

    transaction do
      items.where(cover: true).update_all(cover: false)
      item.update!(cover: true)
    end
  end
end
