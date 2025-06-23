require 'rails_helper'

RSpec.describe ChatController, type: :request do
  describe 'GET /chat' do
    it 'returns a successful response and displays the chat form' do
      get chat_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('form')
      expect(response.body).to include('message')
    end
  end

  describe 'POST /chat' do
    it 'is pending implementation for chat message creation' do
      skip 'TODO: Add a test for ChatController#create action'
    end
  end
end