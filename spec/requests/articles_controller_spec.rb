require 'rails_helper'

RSpec.describe ArticlesController, type: :request do
  let(:current_user) { create(:user, :moderator) }

  before do
    current_user.confirm
    sign_in current_user
  end

  describe 'GET /articles' do
    let!(:articles) { create_list(:article, 3, visibility_level: :public_visibility) }

    it 'returns a successful response and displays article page body' do
      get articles_path
      expect(response).to have_http_status(:ok)
      articles.each do |article|
        expect(response.body).to include(article.page.body.to_plain_text)
      end
    end
  end

  describe 'GET /articles/:id' do
    let!(:article) { create(:article, visibility_level: :public_visibility) }

    it 'returns a successful response and displays the article content' do
      get article_path(article)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(article.page.body.to_plain_text)
    end
  end

  describe 'GET /articles/new' do
    let!(:article) { create(:article) }
    it 'returns a successful response and does not display any existing article page body' do
      get new_article_path
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(article.page.body.to_plain_text)
    end
  end

  describe 'POST /articles' do
    let(:folder) { create(:folder) }
    let(:article_body) { FFaker::Lorem.paragraph }
    let(:valid_params) do
      {
        article: {
          title: FFaker::Lorem.sentence,
          page: article_body,
          parent_id: folder.id
        }
      }
    end

    it 'creates an article and displays its page body' do
      post articles_path, params: valid_params
      article = Article.order(:created_at).last
      expect(response).to redirect_to(folder_path(article.parent))
      follow_redirect!
      expect(response.body).to include(article.title)
    end
  end

  describe 'PATCH /articles/:id' do
    let!(:article) { create(:article, author: current_user) }
    let(:new_body) { FFaker::Lorem.paragraph }
    let(:update_params) do
      {
        article: {
          page: new_body
        }
      }
    end

    it 'updates the article and displays the new page body' do
      patch article_path(article), params: update_params
      expect(response).to redirect_to(article_path(article))
      follow_redirect!
      article.reload
      expect(response.body).to include(article.page.body.to_plain_text)
    end
  end

  describe 'DELETE /articles/:id' do
    let!(:article) { create(:article, author: current_user) }

    it 'destroys the article and redirects to index, article content is not present' do
      delete article_path(article)
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(Article.exists?(article.id)).to be_falsey
      expect(response.body).not_to include(article.page.body.to_plain_text)
    end
  end

  # TODO: check user permissions for each action below.
  # Each example should verify that the correct role (member / moderator / admin / guest)
  # is allowed or denied access, and that the response matches the expected behaviour.
  context 'authorization' do
    it 'allows a guest to view a public article' do
      skip 'user permission checks not yet implemented'
    end

    it 'denies a guest access to an internal article' do
      skip 'user permission checks not yet implemented'
    end

    it 'denies a member from creating an article' do
      skip 'user permission checks not yet implemented'
    end

    it 'denies a member from updating an article' do
      skip 'user permission checks not yet implemented'
    end

    it 'denies a member from deleting an article' do
      skip 'user permission checks not yet implemented'
    end

    it 'allows a moderator to create an article' do
      skip 'user permission checks not yet implemented'
    end

    it 'allows an admin to destroy an article' do
      skip 'user permission checks not yet implemented'
    end
  end
end
