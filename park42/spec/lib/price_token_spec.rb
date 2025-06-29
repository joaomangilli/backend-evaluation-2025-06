require 'rails_helper'

RSpec.describe PriceToken do
  describe '.generate and .decrypt' do
    it 'returns the original data' do
      start_at = Time.utc(2025, 6, 1)
      end_at = Time.utc(2025, 6, 2)
      price = 50_000
      currency = 'BRL'

      token = described_class.generate(start_at: start_at, end_at: end_at, price: price, currency: currency)
      data = described_class.decrypt(token)

      expect(data).to eq({ start_at: start_at.iso8601, end_at: end_at.iso8601, price: price, currency: currency })
    end
  end
end
