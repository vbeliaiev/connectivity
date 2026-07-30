class PdfNotesController < ApplicationController
  after_action :verify_pundit_authorization
  before_action :set_pdf_note, only: %i[ show edit update destroy toggle_visibility ]

  def show
    authorize @pdf_note
  end

  def new
    @pdf_note = PdfNote.new
    authorize @pdf_note
    set_parent_or_parent_scope
  end

  def edit
    authorize @pdf_note
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

  def update
    authorize @pdf_note

    if @pdf_note.update(pdf_note_update_params)
      redirect_to @pdf_note, notice: "Pdf note was successfully updated."
    else
      render :edit, status: :unprocessable_entity
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

  def toggle_visibility
    authorize @pdf_note, :update?

    new_level = @pdf_note.public_visibility? ? :internal : :public_visibility

    if @pdf_note.update(visibility_level: new_level)
      redirect_to redirect_path, notice: "Pdf note visibility was successfully updated."
    else
      redirect_to redirect_path, alert: 'Pdf note visibility was not updated. Please try again and notify administrator.'
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
    permitted = params.require(:pdf_note).permit(:title, :file, :parent_id, :visibility_level)
    permitted = permitted.except(:visibility_level) unless current_user&.moderator? || current_user&.admin?
    permitted
  end

  # Same as pdf_note_params, but drops :file when no new file was chosen so
  # the existing attachment is left untouched (the file input has no value
  # to fall back on, unlike a text field).
  def pdf_note_update_params
    permitted = pdf_note_params.except(:parent_id)
    permitted = permitted.except(:file) if permitted[:file].blank?
    permitted
  end

  def folder_policy_scope
    FolderPolicy::Scope.new(current_user, Folder.all).resolve
  end
end
