require 'rails_helper'

RSpec.describe CreatePaymentService, type: :service do
  subject(:create_payment_service) { described_class.new(payment_token:, amount:, reservation_id:, url:) }

  let(:payment_token) { 'payment_token_123' }
  let(:amount) { 50_000 }
  let(:reservation_id) { 456 }
  let(:url) { 'https://example.com' }

  describe '#create!' do
    before do
      allow(RestClient).to receive(:post).and_return(response)
      allow(UpdateReservationStatusService).to receive(:update!)
    end

    let(:response) do
      double(
        success?: response_success?,
        status: response_status,
        body: response_body
      )
    end

    let(:response_success?) { true }
    let(:response_status) { 200 }
    let(:response_body) { { errors: [ 'Payment creation failed' ] } }

    it 'creates a new payment successfully' do
      expect(RestClient).to receive(:post).with(
        url: "#{url}/payments",
        payload: { payment_token:, amount:, reservation_id: }
      )

      create_payment_service.create!
    end

    it 'does not update the reservation status' do
      expect(UpdateReservationStatusService).not_to receive(:update!)

      create_payment_service.create!
    end

    context 'when response is not successful' do
      let(:response_success?) { false }

      it 'updates the reservation status' do
        expect(UpdateReservationStatusService).to receive(:update!).with(
          reservation_id:,
          status: :failed
        )

        create_payment_service.create!
      end

      it 'logs an error' do
        expect(Rails.logger).to receive(:error).with('Payment creation failed')

        create_payment_service.create!
      end
    end

    context 'when RestClient raises an error' do
      before do
        allow(RestClient).to receive(:post).and_raise(RestClient::Error.new('Network error'))
      end

      it 'raises CreatePaymentService::Error' do
        expect { create_payment_service.create! }.to raise_error(
          CreatePaymentService::Error,
          'Network error'
        )
      end

      it 'does not update the reservation status' do
        expect(UpdateReservationStatusService).not_to receive(:update!)

        expect { create_payment_service.create! }.to raise_error(CreatePaymentService::Error)
      end
    end
  end
end
