class NotesController < ApplicationController
  after_action :verify_pundit_authorization
  before_action :set_note, only: %i[ show edit update destroy ]

  SEMANTIC_SEARCH_ITEMS_COUNT = 3

  # GET /notes or /notes.json
  def index
    query = params[:query]
    @folders = Folder.ordered

    if query
      query_embedding = EmbeddingGenerator.generate(query)
      @notes = policy_scope(Note).semantic_search(query_embedding, top: SEMANTIC_SEARCH_ITEMS_COUNT)
    else
      @notes = policy_scope(Note)
    end

  end

  # GET /notes/1 or /notes/1.json
  def show
    authorize @note
  end

  # GET /notes/new
  def new
    @note = Note.new
    authorize @note
  end

  # GET /notes/1/edit
  def edit
    authorize @note
  end

  # POST /notes or /notes.json
  def create
    @note = Note.new(note_params.merge(author: current_user,
                                       organisation: current_user.current_organisation))
    authorize @note
    respond_to do |format|
      if @note.save
        format.html { redirect_to @note, notice: "Note was successfully created." }
        format.json { render :show, status: :created, location: @note }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notes/1 or /notes/1.json
  def update
    authorize @note
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to @note, notice: "Note was successfully updated." }
        format.json { render :show, status: :ok, location: @note }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1 or /notes/1.json
  def destroy
    authorize @note
    @note.destroy!

    respond_to do |format|
      format.html { redirect_to notes_path, status: :see_other, notice: "Note was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def verify_pundit_authorization
    if action_name == "index"
      verify_policy_scoped
    else
      verify_authorized
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_note
    @note = Note.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def note_params
    params.require(:note).permit(:content, :page, :parent_id)
  end
end
