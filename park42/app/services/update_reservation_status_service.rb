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

    reservation.update!(status:)
  end

  private

  def reservation
    @reservation ||= Reservation.find(reservation_id)
  end
end
