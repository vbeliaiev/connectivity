require 'rails_helper'
require 'dry/monads'

RSpec.describe ChatController, type: :request do
  include Dry::Monads[:result]

  describe 'GET /chat' do
    it 'returns a successful response and displays the chat form' do
      get chat_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('form')
      expect(response.body).to include('message')
    end
  end

  describe 'POST /chat' do
    let(:ai_chat_service_double) { instance_double(AiChatService) }
    let(:chat_history) { [{ 'role' => 'user', 'content' => 'Hello' }] }
    let(:new_chat_history) { chat_history + [{ 'role' => 'assistant', 'content' => 'Hi there!' }] }

    before do
      allow(AiChatService).to receive(:new).and_return(ai_chat_service_double)
    end

    context 'when AiChatService succeeds' do
      before do
        allow(ai_chat_service_double).to receive(:call).and_return(Success(new_chat_history))
      end

      it 'calls AiChatService and updates chat_history in session' do
        session_double = {}.with_indifferent_access
        session_double[:chat_history] = chat_history
        allow_any_instance_of(ChatController).to receive(:session).and_return(session_double)

        post chat_path, params: { message: 'Hello' }

        expect(ai_chat_service_double).to have_received(:call).with('Hello', chat_history)
        expect(session_double[:chat_history]).to eq(new_chat_history)
        expect(flash[:warn]).to be_nil
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Chat with GPT')
      end
    end

    context 'when AiChatService fails' do
      let(:error_message) { 'Something went wrong' }

      before do
        allow(ai_chat_service_double).to receive(:call).and_return(Failure(error_message))
      end

      it 'calls AiChatService and sets a flash warning' do
        session_double = {}.with_indifferent_access
        session_double[:chat_history] = chat_history
        allow_any_instance_of(ChatController).to receive(:session).and_return(session_double)

        post chat_path, params: { message: 'Hello' }

        expect(ai_chat_service_double).to have_received(:call).with('Hello', chat_history)
        expect(session_double[:chat_history]).to eq(chat_history)
        expect(flash[:warn]).to eq(error_message)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Chat with GPT')
      end
    end
  end
end