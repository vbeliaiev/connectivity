class NotesController < ApplicationController
  after_action :verify_pundit_authorization
  before_action :set_note, only: %i[ show edit update destroy ]

  SEMANTIC_SEARCH_ITEMS_COUNT = 3
  FOLDER_ITEMS_MAX_COUNT = 10
  NOTE_ITEMS_MAX_COUNT = 10

  def index
    query = params[:query]

    @folders = folder_policy_scope.root_records.ordered.page(params[:folders_page]).per(FOLDER_ITEMS_MAX_COUNT)

    if query
      query_embedding = EmbeddingGenerator.generate(query)
      @notes = note_policy_scope.semantic_search(query_embedding, top: SEMANTIC_SEARCH_ITEMS_COUNT)
    else
      @notes = note_policy_scope
    end

    @notes = @notes.includes(:rich_text_page).page(params[:notes_page]).per(NOTE_ITEMS_MAX_COUNT)
  end

  def show
    authorize @note
  end

  def new
    @note = Note.new
    authorize @note
    set_parent_or_parent_scope
  end

  def edit
    authorize @note
    @folder_policy_scope = folder_policy_scope
  end

  def create
    @note = Note.new(note_params.merge(author: current_user,
                                       organisation: current_user.current_organisation))
    authorize @note

    if @note.save
      redirect_to redirect_path, notice: "Note was successfully created."
    else
      set_parent_or_parent_scope
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @note

    if @note.update(note_params)
      redirect_to @note, notice: "Note was successfully updated."
    else
      @folder_policy_scope = folder_policy_scope
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @note

    if @note.destroy!
      redirect_to redirect_path, notice: "Note was successfully destroyed."
    else
      redirect_to redirect_path, alert: 'Note was not destroyed. Please try angain and notify administrator.'
    end

  end

  private

  def redirect_path
    @note.parent_id ? folder_path(@note.parent_id) : root_path
  end

  def set_parent_or_parent_scope
    if params[:parent_id]
      @parent = folder_policy_scope.find(params[:parent_id])
    else
      @folder_policy_scope = folder_policy_scope
    end
  end

  def set_note
    @note = Note.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:content, :page, :parent_id)
  end

  def note_policy_scope
    policy_scope(Note)
  end

  def folder_policy_scope
    FolderPolicy::Scope.new(current_user, Folder.all).resolve
  end
end
