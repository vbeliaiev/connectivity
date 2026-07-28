require 'rails_helper'

RSpec.describe Country, type: :model do
  describe 'associations' do
    it { should have_many(:catalog_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
