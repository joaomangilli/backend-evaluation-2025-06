class UpdateReservationStatusJob < ApplicationJob
  sidekiq_options queue: :default, retry: 3

  def perform(reservation_id, status)
    UpdateReservationStatusService.update!(reservation_id:, status:)
  end
end
