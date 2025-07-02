require 'rails_helper'

RSpec.describe CreateReservationService, type: :service do
  let(:user) { create(:user) }
  let(:start_at) { 1.day.from_now.iso8601 }
  let(:end_at) { 2.days.from_now.iso8601 }
  let(:amount) { 50_000 }
  let(:currency) { 'BRL' }
  let(:price_token) { 'valid_price_token_123' }
  let(:payment_token) { 'payment_token_456' }
  let(:price_token_valid?) { true }

  subject(:reservation_service) do
    described_class.new(
      user:,
      price_token:,
      payment_token:,
      start_at:,
      end_at:,
      amount:,
      currency:
    )
  end

  describe '#create!' do
    before do
      allow(PriceToken).to receive(:valid?).and_return(price_token_valid?)
      allow(CreatePaymentJob).to receive(:perform_async)
    end

    it 'creates a new reservation successfully' do
      reservation = reservation_service.create!

      expect(reservation).to be_persisted
      expect(reservation.user).to eq(user)
      expect(reservation.price_token).to eq(price_token)
      expect(reservation.payment_token).to eq(payment_token)
      expect(reservation.amount).to eq(amount)
      expect(reservation.start_at.iso8601).to eq(start_at)
      expect(reservation.end_at.iso8601).to eq(end_at)
      expect(reservation.status).to eq('pending')
    end

    it 'enqueues payment job with correct parameters' do
      expect(CreatePaymentJob).to receive(:perform_async).with(
        payment_token,
        amount,
        anything
      )

      reservation_service.create!
    end

    context 'when reservation already exists' do
      let!(:existing_reservation) { create(:reservation, user:, price_token:, payment_token:, start_at:, end_at:, amount:) }

      it 'returns existing reservation without creating a new one' do
        expect(reservation_service.create!).to eq(existing_reservation)
      end

      it 'does not create a reservation' do
        expect(Reservation).not_to receive(:create!)

        reservation_service.create!
      end

      it 'does not enqueue payment job' do
        expect(CreatePaymentJob).not_to receive(:perform_async)

        reservation_service.create!
      end
    end

    context 'when reservation already exists (race condition)' do
      before { allow(Reservation).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique) }

      it 'does not enqueue payment job' do
        expect(CreatePaymentJob).not_to receive(:perform_async)

        reservation_service.create!
      end
    end

    context 'when price token is invalid' do
      let(:price_token_valid?) { false }

      it 'raises an error' do
        expect { reservation_service.create! }.to raise_error(
          CreateReservationService::Error,
          'Invalid price token'
        )
      end

      it 'does not create a reservation' do
        expect(Reservation).not_to receive(:create!)
        expect { reservation_service.create! }.to raise_error(CreateReservationService::Error)
      end

      it 'does not enqueue payment job' do
        expect(CreatePaymentJob).not_to receive(:perform_async)
        expect { reservation_service.create! }.to raise_error(CreateReservationService::Error)
      end
    end

    context 'when params are invalid' do
      let(:amount) { -100 }

      it 'raises an error' do
        expect { reservation_service.create! }.to raise_error(
          CreateReservationService::Error,
          'Amount must be greater than 0'
        )
      end

      it 'does not enqueue payment job' do
        expect(CreatePaymentJob).not_to receive(:perform_async)
        expect { reservation_service.create! }.to raise_error(CreateReservationService::Error)
      end
    end
  end
end
