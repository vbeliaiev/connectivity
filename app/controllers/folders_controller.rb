class FoldersController < ApplicationController
  after_action :verify_pundit_authorization

  before_action :set_folder, only: %i[ show edit update destroy ]

  def show
    authorize @folder
    @child_articles = @folder.child_articles(params[:articles_page])
    @child_folders = @folder.child_folders(params[:folders_page])
    @child_pdf_notes = @folder.child_pdf_notes(params[:pdf_notes_page])
    @child_video_notes = @folder.child_video_notes(params[:video_notes_page])
    @child_photo_galleries = @folder.child_photo_galleries(params[:photo_galleries_page])
  end

  def new
    @folder = Folder.new
    authorize @folder

    set_parent_or_parent_scope
  end

  def edit
    authorize @folder
    @policy_scope = policy_scope(Folder)
  end

  def create
    @folder = Folder.new(folder_params.merge(author: current_user,
                                             organisation: current_user.current_organisation))

    authorize @folder


    if @folder.save
      redirect_to @folder, notice: "Folder was successfully created."
    else
      set_parent_or_parent_scope
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @folder

    if @folder.update(folder_params)
      redirect_to @folder, notice: "Folder was successfully updated."
    else
      @policy_scope = policy_scope(Folder)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @folder

    if @folder.destroy!
      redirect_path = @folder.parent_id ? folder_path(@folder.parent_id) : root_path
      redirect_to redirect_path, notice: "Folder was successfully destroyed."
    else
      redirect_to folder_path(@folder), alert: 'Folder was not destroyed. Please try angain and notify administrator.'
    end
  end

  private

  def set_parent_or_parent_scope
    if params[:parent_id]
      @parent = policy_scope(Folder).find(params[:parent_id])
    else
      @policy_scope = policy_scope(Folder)
    end
  end

  def set_folder
    @folder = Folder.find(params[:id])
  end

  def folder_params
    params.require(:folder).permit(:title, :parent_id)
  end
end
