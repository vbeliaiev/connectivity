class VideoNotesController < ApplicationController
  after_action :verify_pundit_authorization
  before_action :set_video_note, only: %i[ show destroy ]

  def show
    authorize @video_note
  end

  def new
    @video_note = VideoNote.new
    authorize @video_note
    set_parent_or_parent_scope
  end

  def create
    @video_note = VideoNote.new(video_note_params.merge(author: current_user))
    authorize @video_note

    if @video_note.save
      redirect_to redirect_path, notice: "Video note was successfully created."
    else
      set_parent_or_parent_scope
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @video_note

    if @video_note.destroy!
      redirect_to redirect_path, notice: "Video note was successfully destroyed."
    else
      redirect_to redirect_path, alert: 'Video note was not destroyed. Please try again and notify administrator.'
    end
  end

  private

  def redirect_path
    @video_note.parent_id ? folder_path(@video_note.parent_id) : root_path
  end

  def set_parent_or_parent_scope
    if params[:parent_id]
      @parent = folder_policy_scope.find(params[:parent_id])
    else
      @folder_policy_scope = folder_policy_scope
    end
  end

  def set_video_note
    @video_note = VideoNote.find(params[:id])
  end

  def video_note_params
    params.require(:video_note).permit(:title, :file, :parent_id)
  end

  def folder_policy_scope
    FolderPolicy::Scope.new(current_user, Folder.all).resolve
  end
end
