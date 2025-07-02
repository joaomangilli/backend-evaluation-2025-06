class CreatePaymentJob < ApplicationJob
  sidekiq_options queue: :default, retry: 3

  sidekiq_retries_exhausted do |job|
    UpdateReservationStatusService.update!(reservation_id: job["args"][2], status: :failed)
  end

  def perform(payment_token, amount, reservation_id)
    CreatePaymentService.create!(
      payment_token:,
      amount:,
      reservation_id:
    )
  end
end
