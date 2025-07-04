require 'rails_helper'

describe ChatPolicy do
  subject { described_class }

  permissions :new?, :create? do
    context 'when user is logged in' do
      let(:user) { create(:user) }

      it 'grantes permissions' do
        expect(subject).to permit(user, nil)
      end
    end

    context 'when user is not logged in' do
      let(:user) { nil }

      it 'declines access' do
        expect(subject).not_to permit(user, nil)
      end
    end
  end

end