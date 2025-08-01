require 'rails_helper'

RSpec.describe NotesController, type: :request do
  let(:current_user) { create(:user) }
  let(:current_user_org) { create(:organisation) }

  before do
    current_user.confirm
    current_user.update(current_organisation_id: current_user_org.id)
    create(:organisations_user, user: current_user, organisation: current_user_org)
    sign_in current_user
  end

  describe 'GET /notes' do
    let!(:notes) { create_list(:note, 3, visibility_level: :public_visibility, organisation: current_user_org) }
    context 'when query is nil' do
      it 'returns a successful response and displays note page body' do
        get notes_path
        expect(response).to have_http_status(:ok)
        notes.each do |note|
          expect(response.body).to include(note.page.body.to_plain_text)
        end
      end
    end

    context 'when query is present (semantic search branch)' do
      let(:search_query) { 'Italian food' }
      let(:search_query_embedding) { 'Italian food - Embedding' }

      it 'builds embedding vector, call semantic search and renders the page successfully' do
        expect(EmbeddingGenerator).to receive(:generate).with(search_query).and_return(search_query_embedding)
        searched_notes = Note.where(id: notes.map(&:id))
        expect(Note).to receive(:semantic_search).with(search_query_embedding, top: described_class::SEMANTIC_SEARCH_ITEMS_COUNT).and_return(searched_notes)

        get notes_path, params: { query: 'Italian food' }

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /notes/:id' do
    let!(:note) { create(:note, visibility_level: :public_visibility) }

    it 'returns a successful response and displays the note content' do
      get note_path(note)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(note.page.body.to_plain_text)
    end
  end

  describe 'GET /notes/new' do
    let!(:note) { create(:note) }
    it 'returns a successful response and does not display any existing note page body' do
      get new_note_path
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(note.page.body.to_plain_text)
    end
  end

  describe 'POST /notes' do
    let(:folder) { create(:folder, organisation: current_user_org) }
    let(:note_body) { FFaker::Lorem.paragraph }
    let(:valid_params) do
      {
        note: {
          title: FFaker::Lorem.sentence,
          page: note_body,
          parent_id: folder.id
        }
      }
    end

    it 'creates a note and displays its page body' do
      post notes_path, params: valid_params
      note = Note.order(:created_at).last
      expect(response).to redirect_to(folder_path(note.parent))
      follow_redirect!
      expect(response.body).to include(note.page.body.to_plain_text)
    end
  end

  describe 'PATCH /notes/:id' do
    let!(:note) { create(:note, author: current_user) }
    let(:new_body) { FFaker::Lorem.paragraph }
    let(:update_params) do
      {
        note: {
          page: new_body
        }
      }
    end

    it 'updates the note and displays the new page body' do
      patch note_path(note), params: update_params
      expect(response).to redirect_to(note_path(note))
      follow_redirect!
      note.reload
      expect(response.body).to include(note.page.body.to_plain_text)
    end
  end

  describe 'DELETE /notes/:id' do
    let!(:note) { create(:note, author: current_user) }

    it 'destroys the note and redirects to index, note content is not present' do
      delete note_path(note)
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(Note.exists?(note.id)).to be_falsey
      expect(response.body).not_to include(note.page.body.to_plain_text)
    end
  end
end