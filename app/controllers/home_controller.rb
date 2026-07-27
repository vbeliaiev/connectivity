class HomeController < ApplicationController
  after_action :verify_pundit_authorization

  SEMANTIC_SEARCH_ITEMS_COUNT = 3

  def index
    @query = params[:query]

    if @query.present?
      query_embedding = EmbeddingGenerator.generate(@query)
      @notes = policy_scope(Note).semantic_search(query_embedding, top: SEMANTIC_SEARCH_ITEMS_COUNT)
    else
      skip_policy_scope
      @root_folders = @sidebar_folders
    end
  end
end
