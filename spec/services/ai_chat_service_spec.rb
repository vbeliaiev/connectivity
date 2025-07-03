# frozen_string_literal: true

# spec/services/ai_chat_service_spec.rb
# Skeleton spec for AiChatService
require 'rails_helper'

RSpec.describe AiChatService, type: :service do
  let(:service) { described_class.new }
  let(:user_input) { 'Test input' }
  let(:chat_history) { nil }
  let(:current_user) { create(:user) }

  before do
    allow(Rails.application).to receive(:credentials).and_return({ openai_key: 'test-key' })
    current_user.confirm
  end

  subject { service.call(user_input, chat_history:, current_user:) }

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
        expect { subject }.to change(Note, :count).by(1)
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
        expect(subject).to be_success
        expect(subject.value!.last['content']).to eq('Just a plain message from AI.')
      end
    end

    context 'when an error occurs in get_ai_response' do
      before do
        expect(service).to receive(:get_ai_response).and_raise(StandardError, 'AI error!')
      end

      it 'returns a failure result with the error message' do

        expect(subject).to be_failure
        expect(subject.failure).to eq('AI error!')
      end
    end
  end
end