class UpdateReservationStatusService
  attr_reader :reservation_id, :status

  def self.update!(reservation_id:, status:)
    new(reservation_id:, status:).update!
  end

  def initialize(reservation_id:, status:)
    @reservation_id = reservation_id
    @status = status
  end

  def update!
    return if status == reservation.status
    return unless reservation.pending?

    ActiveRecord::Base.transaction do
      reservation.update!(status:)

      ReservationDatesService.create!(
        start_at: reservation.start_at,
        end_at: reservation.end_at,
        increment: -1
      ) if decrement?
    end
  end

  private

  def reservation
    @reservation ||= Reservation.find(reservation_id)
  end

  def decrement?
    [ "failed", "expired" ].include?(status.to_s)
  end
end
