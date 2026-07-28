class ArticlesController < ApplicationController
  after_action :verify_pundit_authorization
  before_action :set_article, only: %i[ show edit update destroy ]

  ARTICLE_ITEMS_MAX_COUNT = 10

  def index
    @articles = article_policy_scope.order(created_at: :desc)
    @articles = @articles.includes(:rich_text_page).page(params[:articles_page]).per(ARTICLE_ITEMS_MAX_COUNT)
  end

  def show
    authorize @article
  end

  def new
    @article = Article.new
    authorize @article
    set_parent_or_parent_scope
  end

  def edit
    authorize @article
    @folder_policy_scope = folder_policy_scope
  end

  def create
    @article = Article.new(article_params.merge(author: current_user))
    authorize @article

    if @article.save
      redirect_to redirect_path, notice: "Article was successfully created."
    else
      set_parent_or_parent_scope
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @article

    if @article.update(article_params)
      redirect_to @article, notice: "Article was successfully updated."
    else
      @folder_policy_scope = folder_policy_scope
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @article

    if @article.destroy!
      redirect_to redirect_path, notice: "Article was successfully destroyed."
    else
      redirect_to redirect_path, alert: 'Article was not destroyed. Please try angain and notify administrator.'
    end

  end

  private

  def redirect_path
    @article.parent_id ? folder_path(@article.parent_id) : root_path
  end

  def set_parent_or_parent_scope
    if params[:parent_id]
      @parent = folder_policy_scope.find(params[:parent_id])
    else
      @folder_policy_scope = folder_policy_scope
    end
  end

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    permitted = params.require(:article).permit(:title, :content, :page, :parent_id, :visibility_level)
    permitted = permitted.except(:visibility_level) unless current_user&.moderator? || current_user&.admin?
    permitted
  end

  def article_policy_scope
    policy_scope(Article)
  end

  def folder_policy_scope
    FolderPolicy::Scope.new(current_user, Folder.all).resolve
  end
end
