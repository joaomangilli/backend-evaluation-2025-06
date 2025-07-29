require 'rails_helper'

RSpec.describe DeleteReservationDatesJob, type: :job do
  let(:old_records) { ReservationDate.where("reservation_at < ?", Date.current) }
  let(:records) { ReservationDate.where("reservation_at >= ?", Date.current) }

  describe '#perform' do
    before do
      create(:reservation_date, reservation_at: 1.day.ago)
      create(:reservation_date, reservation_at: 2.days.ago)
      create(:reservation_date, reservation_at: 3.days.ago)

      create(:reservation_date, reservation_at: Time.current)
      create(:reservation_date, reservation_at: 1.days.from_now)

      described_class.new.perform
    end

    it 'deletes old reservation dates' do
      expect(old_records).to be_empty
    end

    it 'does not delete reservation dates' do
      expect(records.count).to eq(2)
    end
  end
end
