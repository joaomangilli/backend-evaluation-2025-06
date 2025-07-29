class ReservationDatesService
  class Error < StandardError; end

  attr_reader :start_at, :end_at, :increment

  def self.create!(start_at:, end_at:, increment: 1)
    new(start_at:, end_at:, increment:).create!
  end

  def initialize(start_at:, end_at:, increment:)
    @start_at = start_at.to_date
    @end_at = end_at.to_date
    @increment = increment
  end

  def create!
    (start_at..end_at).each do |date|
      reservation_date = ReservationDate.find_or_initialize_by(reservation_at: date)

      reservation_date.update!(reservation_count: reservation_date.reservation_count.to_i + increment)
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::StaleObjectError
      raise Error, "We could not create the reservation for the given range. Please try again."
    rescue ActiveRecord::RecordInvalid => e
      raise Error, e.record.errors.full_messages.join(", ")
    end
  end
end
