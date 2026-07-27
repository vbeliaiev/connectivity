require 'rails_helper'

RSpec.describe Article, type: :model do
  it { should define_enum_for(:visibility_level).with_values(internal: 0, public_visibility: 1) }
end
