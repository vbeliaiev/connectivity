class HomeController < ApplicationController
  after_action :verify_pundit_authorization

  def index
    @query = params[:query]

    if @query.present?
      scope = policy_scope(Node)
      @folders = scope.folders.content_search(@query)
      @articles = scope.articles.content_search(@query)
      @pdf_notes = scope.pdf_notes.content_search(@query).includes(file_attachment: :blob)
      @video_notes = scope.video_notes.content_search(@query).includes(file_attachment: :blob)
      @photo_galleries = scope.photo_galleries.content_search(@query).includes(items: { image_attachment: :blob })
    else
      skip_policy_scope
      @root_folders = @sidebar_folders
    end
  end
end
