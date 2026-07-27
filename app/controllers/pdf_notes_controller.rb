class PdfNotesController < ApplicationController
  after_action :verify_pundit_authorization
  before_action :set_pdf_note, only: %i[ show destroy ]

  def show
    authorize @pdf_note
  end

  def new
    @pdf_note = PdfNote.new
    authorize @pdf_note
    set_parent_or_parent_scope
  end

  def create
    @pdf_note = PdfNote.new(pdf_note_params.merge(author: current_user))
    authorize @pdf_note

    if @pdf_note.save
      redirect_to redirect_path, notice: "Pdf note was successfully created."
    else
      set_parent_or_parent_scope
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @pdf_note

    if @pdf_note.destroy!
      redirect_to redirect_path, notice: "Pdf note was successfully destroyed."
    else
      redirect_to redirect_path, alert: 'Pdf note was not destroyed. Please try again and notify administrator.'
    end
  end

  private

  def redirect_path
    @pdf_note.parent_id ? folder_path(@pdf_note.parent_id) : root_path
  end

  def set_parent_or_parent_scope
    if params[:parent_id]
      @parent = folder_policy_scope.find(params[:parent_id])
    else
      @folder_policy_scope = folder_policy_scope
    end
  end

  def set_pdf_note
    @pdf_note = PdfNote.find(params[:id])
  end

  def pdf_note_params
    params.require(:pdf_note).permit(:title, :file, :parent_id)
  end

  def folder_policy_scope
    FolderPolicy::Scope.new(current_user, Folder.all).resolve
  end
end
