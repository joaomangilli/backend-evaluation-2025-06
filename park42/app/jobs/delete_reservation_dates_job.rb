class DeleteReservationDatesJob < ApplicationJob
  sidekiq_options queue: :default, retry: 1

  def perform
    ReservationDate.where("reservation_at < ?", Date.current).delete_all
  end
end
