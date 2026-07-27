require 'rails_helper'

describe NodePolicy do
  subject { described_class.new(user, node) }

  shared_examples 'allows read-only access' do
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  shared_examples 'allows full access' do
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'when user is a member' do
    let(:user) { build(:user) }
    let(:node) { build(:folder) }

    include_examples 'allows read-only access'
  end

  context 'when user is a moderator' do
    let(:user) { build(:user, :moderator) }
    let(:node) { build(:folder) }

    include_examples 'allows full access'
  end

  context 'when user is an admin' do
    let(:user) { build(:user, :admin) }
    let(:node) { build(:folder) }

    include_examples 'allows full access'
  end

  context 'when user is not logged in (guest)' do
    let(:user) { nil }

    context 'with a public node' do
      let(:node) { build(:folder, visibility_level: :public_visibility) }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:index) }
    end

    context 'with an internal node' do
      let(:node) { build(:folder, visibility_level: :internal) }

      it { is_expected.to forbid_action(:show) }
    end
  end

  describe 'Scope' do
    subject(:resolved) { described_class::Scope.new(user, Node).resolve }

    context 'when user is logged in' do
      let(:user) { build(:user) }

      it 'returns all records' do
        expect(resolved).to eq(Node.all)
      end
    end

    context 'when user is a guest' do
      let(:user) { nil }

      it 'returns only public records' do
        expect(resolved).to eq(Node.where(visibility_level: :public_visibility))
      end
    end
  end
end
