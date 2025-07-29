require 'rails_helper'

RSpec.describe UpdateReservationStatusJob, type: :job do
  let(:reservation_id) { 123 }
  let(:status) { :expired }

  describe '#perform' do
    after { described_class.new.perform(reservation_id, status) }

    it 'calls UpdateReservationStatusService with correct parameters' do
      expect(UpdateReservationStatusService).to receive(:update!).with(
        reservation_id:,
        status:
      )
    end
  end
end
