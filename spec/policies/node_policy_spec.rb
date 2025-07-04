require 'rails_helper'

describe NodePolicy do
  let!(:user) { create(:user) }

  subject { described_class }

  permissions :update?, :destroy? do
    context 'when the user is owner of the note' do
      let!(:note) { create(:note, author: user) }

      it 'grantes permissions' do
        expect(subject).to permit(user, note)
      end
    end

    context 'when the user is not owner of the note' do
      let!(:organisation) { create(:organisation) }
      let!(:note) { create(:note, organisation: organisation) }

      it 'restricts when the user is not a part of organisation' do
        expect(subject).not_to permit(user, note)
      end

      it 'restricts when the user is a member in the organisation' do
        OrganisationsUser.create(user: user, organisation: organisation, role: :member)
        expect(subject).not_to permit(user, note)
      end

      %w[moderator admin owner].each do |role|
        it "permits when the user is #{role} in the organisation" do
          OrganisationsUser.create(user: user, organisation: organisation, role: role)
          expect(subject).to permit(user, note)
        end
      end
    end
  end

  permissions :create? do
    let(:organisation) { create(:organisation) }
    let(:note) { build(:note, author: user)}
    before { user.update(current_organisation: organisation) }


    it 'allows to create a note only when user is in the organisation' do
      OrganisationsUser.create(user: user, organisation: organisation, role: :member)
      expect(subject).to permit(user, note)
    end

    it 'restricts when the user is not a part of the organisation' do
      expect(subject).not_to permit(user, note)
    end
  end

  permissions :show? do
    let(:organisation) { create(:organisation) }
    let(:note) { create(:note, visibility_level: :internal, organisation: organisation) }

    context 'when the user is in the organisation' do
      before { OrganisationsUser.create(user: user, organisation: organisation, role: :member) }

      it 'allows to see all notes' do
        expect(subject).to permit(user, note)
      end
    end

    context 'when the user is not in the organisation' do
      it 'allows to see public notes' do
        note.update(visibility_level: :public_visibility)
        expect(subject).to permit(user, note)
      end

      it 'restricts private notes' do
        expect(subject).not_to permit(user, note)
      end
    end
  end

  permissions :index? do
    let(:user) { create(:user) }

    it 'allows all to get index page' do
      expect(subject).to permit(user, Note)
    end
  end

  describe NotePolicy::Scope do
    let(:resolved_scope) do
      described_class.new(user, Note.all).resolve
    end

    context 'when the user is logged in' do
      let(:user) { create(:user) }
      let(:user_organisation) { create(:organisation) }
      let(:other_organisation) { create(:organisation) }

      let!(:note_user_org) { create(:note, organisation: user_organisation, visibility_level: :internal) }
      let!(:internal_note_other_org) { create(:note, organisation: other_organisation, visibility_level: :internal) }
      let!(:public_note_other_org) { create(:note, organisation: other_organisation, visibility_level: :public_visibility) }

      before { OrganisationsUser.create(user: user, organisation: user_organisation, role: :member) }

      it 'returns either public notes either internal notes for user organisations' do
        expect(resolved_scope).to contain_exactly(note_user_org, public_note_other_org)
      end
    end

    context 'when the user is not logged in' do
      let(:user) { nil }

      let(:public_note) { create(:note, visibility_level: :public_visibility) }
      let(:internal_note) { create(:note, visibility_level: :internal) }

      it 'returns only public notes' do
        expect(resolved_scope).to contain_exactly(public_note)
      end
    end

  end
end