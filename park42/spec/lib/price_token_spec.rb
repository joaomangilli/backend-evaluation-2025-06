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

  describe '.valid?' do
    subject(:valid?) do
      described_class.valid?(token:, start_at: start_at.iso8601, end_at: end_at.iso8601, price:, currency:)
    end

    let(:token) { described_class.generate(start_at:, end_at:, price:, currency:) }
    let(:start_at) { 1.day.from_now }
    let(:end_at) { 2.days.from_now }
    let(:price) { 50_000 }
    let(:currency) { 'BRL' }

    it 'returns true for valid token' do
      expect(valid?).to be_truthy
    end

    context 'when token is invalid' do
      let(:token) { 'invalid_token' }

      it 'returns false for invalid token' do
        expect(valid?).to be_falsey
      end
    end

    context 'when the params are invalid' do
      let(:token) { described_class.generate(start_at:, end_at:, price: 50, currency:) }
      let(:price) { 40_000 }

      it 'returns false for invalid token' do
        expect(valid?).to be_falsey
      end
    end
  end
end
