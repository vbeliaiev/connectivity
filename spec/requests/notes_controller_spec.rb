require 'rails_helper'

RSpec.describe NotesController, type: :request do
  describe 'GET /notes' do
    context 'when query is nil' do
      let!(:notes) { create_list(:note, 3) }

      it 'returns a successful response and displays note page body' do
        get notes_path
        expect(response).to have_http_status(:ok)
        notes.each do |note|
          expect(response.body).to include(note.page.body.to_plain_text)
        end
      end
    end

    context 'when query is present (semantic search branch)' do
      it 'is pending implementation for semantic search' do
        skip 'TODO: Add a test for the semantic search branch (when query is present)'
      end
    end
  end
end