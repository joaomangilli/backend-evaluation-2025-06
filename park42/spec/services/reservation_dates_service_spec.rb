require 'rails_helper'

RSpec.describe ReservationDatesService, type: :service do
  subject(:reservation_dates_service) { described_class.new(start_at:, end_at:, increment:) }

  let(:start_at) { 1.day.from_now }
  let(:end_at) { 30.days.from_now }
  let(:increment) { 1 }

  describe '#create!' do
    let!(:reservation_date) do
      create(:reservation_date, reservation_at: 3.days.from_now.to_date, reservation_count: 5)
    end

    it 'creates new reservation dates successfully' do
      expect { reservation_dates_service.create! }.to change { ReservationDate.count }.by(29)
    end

    it 'increments the reservation count' do
      reservation_dates_service.create!

      expect(reservation_date.reload.reservation_count).to eq(6)
    end

    context 'when increment is negative' do
      let(:start_at) { 3.days.from_now }
      let(:end_at) { 3.days.from_now }
      let(:increment) { -1 }

      it 'decrements the reservation count' do
        reservation_dates_service.create!

        expect(reservation_date.reload.reservation_count).to eq(4)
      end
    end

    context 'when there is no available spots' do
      before { ENV["MAX_SPOTS"] = '5' }

      it 'raises an error' do
        expect { reservation_dates_service.create! }.to(
          raise_error(ReservationDatesService::Error, 'No available parking spots')
        )
      end
    end

    context 'when trying to create concurrently' do
      before do
        allow(ReservationDate).to receive(:find_or_initialize_by).and_raise(ActiveRecord::RecordNotUnique)
      end

      it 'raises an error' do
        expect { reservation_dates_service.create! }.to(
          raise_error(
            ReservationDatesService::Error,
            'We could not create the reservation for the given range. Please try again.'
          )
        )
      end
    end

    context 'when trying to update concurrently' do
      before do
        allow(ReservationDate).to receive(:find_or_initialize_by).and_raise(ActiveRecord::StaleObjectError)
      end

      it 'raises an error' do
        expect { reservation_dates_service.create! }.to(
          raise_error(
            ReservationDatesService::Error,
            'We could not create the reservation for the given range. Please try again.'
          )
        )
      end
    end
  end
end
