require 'rails_helper'

RSpec.describe PriceToken do
  let(:start_at) { Time.utc(2025, 6, 1) }
  let(:end_at)   { Time.utc(2025, 6, 2) }
  let(:price)    { 50_000 }
  let(:currency) { 'BRL' }

  describe '.generate' do
    it 'returns a token string' do
      token = described_class.generate(start_at: start_at, end_at: end_at, price: price, currency: currency)
      expect(token).to be_a(String)
    end
  end

  describe '.decrypt' do
    it 'returns the original data' do
      token = described_class.generate(start_at: start_at, end_at: end_at, price: price, currency: currency)
      data = described_class.decrypt(token)

      expect(data).to eq({ start_at: start_at.iso8601, end_at: end_at.iso8601, price: price, currency: currency })
    end
  end
end
