# frozen_string_literal: true

# spec/services/ai_chat_service_spec.rb
# Skeleton spec for AiChatService
require 'rails_helper'

RSpec.describe AiChatService, type: :service do
  let(:service) { described_class.new }
  let(:user_input) { 'Test input' }
  let(:chat_history) { nil }

  before do
    allow(Rails.application).to receive(:credentials).and_return({ openai_key: 'test-key' })
  end

  describe '#call' do
    context 'when AI returns a tool call' do
      let(:ai_response) do
        double('AIResponse', choices: [ double('Choice', message: double('Message', tool_calls: tool_calls, content: nil )) ])
      end

      let(:tool_calls) do
        [double('ToolCall', function: double('Function', name: 'CreateNote', arguments: { page: 'Note content' }.to_json))]
      end

      before do
        expect(service).to receive(:get_ai_response).and_return(ai_response)
      end

      it 'creates a note with the correct page body' do
        expect { service.call(user_input, chat_history) }.to change(Note, :count).by(1)
        expect(Note.last.page.body.to_plain_text).to eq('Note content')
      end
    end

    context 'when AI returns a plain message' do
      let(:ai_response) do
        double('AIResponse', choices: [
          double('Choice', message: double('Message', tool_calls: nil, content: 'Just a plain message from AI.'))
        ])
      end

      before do
        expect(service).to receive(:get_ai_response).and_return(ai_response)
      end

      it 'returns the plain message in a success result' do
        result = service.call(user_input, chat_history)
        expect(result).to be_success
        expect(result.value!.last['content']).to eq('Just a plain message from AI.')
      end
    end

    context 'when an error occurs in get_ai_response' do
      before do
        expect(service).to receive(:get_ai_response).and_raise(StandardError, 'AI error!')
      end

      it 'returns a failure result with the error message' do
        result = service.call(user_input, chat_history)
        expect(result).to be_failure
        expect(result.failure).to eq('AI error!')
      end
    end
  end
end