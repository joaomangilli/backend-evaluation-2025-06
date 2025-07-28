require 'rails_helper'

RSpec.describe UpdateReservationStatusService, type: :service do
  let(:reservation) { create(:reservation, status:) }
  let(:reservation_id) { reservation.id }
  let(:status) { :pending }
  let(:new_status) { :confirmed }

  subject(:update_reservation_status_service) { described_class.new(reservation_id:, status: new_status) }

  describe '#update!' do
    before { update_reservation_status_service.update! }

    it 'updates reservation status successfully' do
      expect(reservation.reload).to be_confirmed
    end

    context 'when reservation is not pending' do
      let(:status) { :failed }

      it 'does not update reservation status' do
        puts "Current status: #{reservation.reload.status}"
        expect(reservation.reload).to be_failed
      end
    end
  end
end
