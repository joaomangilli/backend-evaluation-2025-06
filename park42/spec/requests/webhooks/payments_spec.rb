require 'rails_helper'

RSpec.describe "POST /webhooks/payment", type: :request do
  let(:reservation) { create(:reservation, status: old_status) }
  let(:reservation_id) { reservation.id }
  let(:secret) { 'secret' }
  let(:status) { 'confirmed' }
  let(:old_status) { 'pending' }

  let(:params) do
    {
      reservation_id:,
      status:
    }.to_json
  end

  let(:headers) do
    {
      'Content-Type' => 'application/json',
      'X-Webhook-Secret' => secret
    }
  end

  before { ENV['PAYMENT_WEBHOOK_SECRET'] = secret }

  it 'returns 200' do
    post('/webhooks/payment', params:, headers:)

    expect(response).to have_http_status(:ok)
  end

  context 'when status is invalid' do
    let(:status) { 'invalid' }

    it 'raises an ArgumentError' do
      expect { post('/webhooks/payment', params:, headers:) }.to raise_error(ArgumentError)
    end
  end

  context 'when the reservation is not pending' do
    let(:old_status) { 'confirmed' }
    let(:status) { 'failed' }

    it 'does not change the reservation status' do
      post('/webhooks/payment', params:, headers:)

      expect(reservation.reload).to be_confirmed
    end
  end

  context 'when the secret token is invalid' do
    before { ENV['PAYMENT_WEBHOOK_SECRET'] = 'invalid' }

    it 'returns 401 Unauthorized' do
      post('/webhooks/payment', params:, headers:)

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
