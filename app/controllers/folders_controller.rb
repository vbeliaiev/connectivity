class FoldersController < ApplicationController
  after_action :verify_pundit_authorization

  before_action :set_folder, only: %i[ show edit update destroy ]

  # GET /folders or /folders.json
  def index
    @folders = policy_scope(Folder)
  end

  # GET /folders/1 or /folders/1.json
  def show
    authorize @folder
  end

  # GET /folders/new
  def new
    @folder = Folder.new
    authorize @folder
  end

  # GET /folders/1/edit
  def edit
    authorize @folder
  end

  # POST /folders or /folders.json
  def create
    @folder = Folder.new(folder_params.merge(author: current_user,
                                             organisation: current_user.current_organisation))

    authorize @folder
    respond_to do |format|
      if @folder.save
        format.html { redirect_to @folder, notice: "Folder was successfully created." }
        format.json { render :show, status: :created, location: @folder }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /folders/1 or /folders/1.json
  def update
    authorize @folder

    respond_to do |format|
      if @folder.update(folder_params)
        format.html { redirect_to @folder, notice: "Folder was successfully updated." }
        format.json { render :show, status: :ok, location: @folder }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /folders/1 or /folders/1.json
  def destroy
    authorize @folder

    @folder.destroy!

    respond_to do |format|
      format.html { redirect_to folders_path, status: :see_other, notice: "Folder was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_folder
      @folder = Folder.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def folder_params
      params.require(:folder).permit(:title)
    end
end
