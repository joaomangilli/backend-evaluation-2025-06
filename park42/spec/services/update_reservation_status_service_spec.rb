require 'rails_helper'

RSpec.describe UpdateReservationStatusService, type: :service do
  let(:reservation) { create(:reservation, status:) }
  let(:reservation_id) { reservation.id }
  let(:status) { :pending }
  let(:new_status) { :confirmed }

  subject(:update_reservation_status_service) { described_class.new(reservation_id:, status: new_status) }

  describe '#update!' do
    before { allow(ReservationDatesService).to receive(:create!) }

    it 'updates reservation status successfully' do
      update_reservation_status_service.update!

      expect(reservation.reload).to be_confirmed
    end

    it 'does not decrement reservation dates' do
      expect(ReservationDatesService).not_to receive(:create!)

      update_reservation_status_service.update!
    end

    context 'when move to failed status' do
      let(:new_status) { :failed }

      it 'updates reservation status to failed' do
        update_reservation_status_service.update!

        expect(reservation.reload).to be_failed
      end

      it 'decrements reservation dates' do
        expect(ReservationDatesService).to receive(:create!).with(
          start_at: reservation.start_at,
          end_at: reservation.end_at,
          increment: -1
        )

        update_reservation_status_service.update!
      end
    end

    context 'when reservation is not pending' do
      let(:status) { :failed }

      it 'does not update reservation status' do
        update_reservation_status_service.update!

        expect(reservation.reload).to be_failed
      end

      it 'does not decrement reservation dates' do
        expect(ReservationDatesService).not_to receive(:create!)

        update_reservation_status_service.update!
      end
    end
  end
end
