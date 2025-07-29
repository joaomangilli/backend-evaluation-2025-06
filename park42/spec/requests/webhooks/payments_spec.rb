require 'rails_helper'

RSpec.describe "POST /webhooks/payment", type: :request do
  let(:reservation) { create(:reservation, status: old_status) }
  let(:reservation_id) { reservation.id }
  let(:secret) { 'secret' }
  let(:status) { 'confirmed' }
  let(:old_status) { 'pending' }
  let(:max_spots) { '5000' }

  let!(:start_at_reservation_date) do
    create(:reservation_date, reservation_at: reservation.start_at, reservation_count: 1)
  end

  let!(:end_at_reservation_date) do
    create(:reservation_date, reservation_at: reservation.end_at, reservation_count: 3)
  end

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

  before do
    ENV["MAX_SPOTS"] = max_spots
    ENV['PAYMENT_WEBHOOK_SECRET'] = secret
  end

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

  describe 'from pending to confirmed' do
    before { post('/webhooks/payment', params:, headers:) }

    let(:old_status) { 'pending' }
    let(:status) { 'confirmed' }

    it 'changes to confirmed' do
      expect(reservation.reload.confirmed?).to be_truthy
    end

    it 'does not change the reservation dates' do
      expect(start_at_reservation_date.reload.reservation_count).to eq(1)
      expect(end_at_reservation_date.reload.reservation_count).to eq(3)
    end
  end

  describe 'from pending to failed' do
    before { post('/webhooks/payment', params:, headers:) }

    let(:old_status) { 'pending' }
    let(:status) { 'failed' }

    it 'changes to failed' do
      expect(reservation.reload.failed?).to be_truthy
    end

    it 'changes the reservation dates' do
      expect(start_at_reservation_date.reload.reservation_count).to eq(0)
      expect(end_at_reservation_date.reload.reservation_count).to eq(2)
    end
  end

  describe 'from pending to expired' do
    before { post('/webhooks/payment', params:, headers:) }

    let(:old_status) { 'pending' }
    let(:status) { 'expired' }

    it 'changes to expired' do
      expect(reservation.reload.expired?).to be_truthy
    end

    it 'changes the reservation dates' do
      expect(start_at_reservation_date.reload.reservation_count).to eq(0)
      expect(end_at_reservation_date.reload.reservation_count).to eq(2)
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
