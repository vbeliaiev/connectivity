require 'rails_helper'

RSpec.describe Note, type: :model do
  it { should belong_to(:organisation) }
  it { should define_enum_for(:visibility_level).with_values(internal: 0, public_visibility: 1) }
end