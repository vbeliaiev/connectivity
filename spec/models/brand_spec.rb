require 'rails_helper'

RSpec.describe Brand, type: :model do
  describe 'associations' do
    it { should have_many(:catalog_items) }
    it { should have_many(:departments) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
  end
end
