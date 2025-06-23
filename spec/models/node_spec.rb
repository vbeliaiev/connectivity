require 'rails_helper'

RSpec.describe Node, type: :model do
  describe 'associations' do
    it { should have_many(:children).class_name('Node').with_foreign_key('parent_id') }
    it { should belong_to(:parent).class_name('Node').optional }
  end

  describe 'scopes' do
    let!(:folder1) { create(:folder, title: 'A', position: 2, created_at: 2.days.ago) }
    let!(:folder2) { create(:folder, title: 'B', position: 1, created_at: 1.day.ago) }
    let!(:note1)   { create(:note, title: 'Note1') }
    let!(:note2)   { create(:note, title: 'Note2') }

    it '.folders returns only folders' do
      expect(Node.folders).to match_array([folder1, folder2])
    end

    it '.notes returns only notes' do
      expect(Node.notes).to match_array([note1, note2])
    end

    it '.ordered returns folders ordered by position ASC NULLS LAST, then created_at DESC' do
      # folder2 has position 1, folder1 has position 2
      expect(Node.folders.ordered).to eq([folder2, folder1])
    end
  end

  describe '.generic_folder' do
    it 'returns a folder with the GENERIC_FOLDER_NAME and position -999' do
      folder = Node.generic_folder
      expect(folder).to be_a(Node)
      expect(folder.title).to eq(Node::GENERIC_FOLDER_NAME)
      expect(folder.position).to eq(-999)
      expect(folder).to be_persisted
    end

    it 'returns the same record on subsequent calls' do
      folder1 = Node.generic_folder
      folder2 = Node.generic_folder
      expect(folder1).to eq(folder2)
    end
  end

  describe '#generic?' do
    it 'returns true for the generic folder' do
      folder = Node.generic_folder
      expect(folder.generic?).to be true
    end

    it 'returns false for a non-generic folder' do
      folder = create(:folder, title: 'NotGeneric')
      expect(folder.generic?).to be false
    end
  end
end