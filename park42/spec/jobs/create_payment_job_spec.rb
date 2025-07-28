require 'rails_helper'

RSpec.describe CreatePaymentJob, type: :job do
  let(:payment_token) { 'payment_token_123' }
  let(:amount) { 50_000 }
  let(:reservation_id) { 456 }

  describe '#perform' do
    after { described_class.new.perform(payment_token, amount, reservation_id) }

    it 'calls CreatePaymentService with correct parameters' do
      expect(CreatePaymentService).to receive(:create!).with(
        payment_token:,
        amount:,
        reservation_id:
      )
    end
  end

  describe 'sidekiq_retries_exhausted callback' do
    let(:job_args) { [ payment_token, amount, reservation_id ] }
    let(:mock_job) { { 'args' => job_args } }

    after { described_class.sidekiq_retries_exhausted_block.call(mock_job) }

    it 'calls UpdateReservationStatusService when retries are exhausted' do
      expect(UpdateReservationStatusService).to receive(:update!).with(
        reservation_id: reservation_id,
        status: :failed
      )
    end
  end
end
