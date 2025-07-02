require 'rails_helper'

RSpec.describe Reservation, type: :model do
  subject(:reservation) { build(:reservation) }

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:price_token) }
    it { should validate_presence_of(:payment_token) }
    it { should validate_presence_of(:status) }

    it { should validate_numericality_of(:amount).is_greater_than(0) }
  end
end
