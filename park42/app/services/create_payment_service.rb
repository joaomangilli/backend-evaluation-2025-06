class CreatePaymentService
  class Error < StandardError; end

  attr_reader :payment_token, :amount, :reservation_id, :url

  def self.create!(payment_token:, amount:, reservation_id:, url: ENV["PAYMENT_URL"])
    new(payment_token:, amount:, reservation_id:, url:).create!
  end

  def initialize(payment_token:, amount:, reservation_id:, url:)
    @payment_token = payment_token
    @amount = amount
    @reservation_id = reservation_id
    @url = url
  end

  def create!
    response = RestClient.post(
      url: "#{url}/payments",
      payload: {
        payment_token:,
        amount:,
        reservation_id:
      }
    )

    if response.success?
      UpdateReservationStatusJob.perform_in(
        reservation_expiration_time_in_minutes,
        reservation_id,
        "expired"
      )
    else
      UpdateReservationStatusService.update!(reservation_id:, status: :failed)

      Rails.logger.error(response.body[:errors].to_a.join(", "))
    end
  rescue RestClient::Error => e
    raise Error, e.message
  end

  private

  def reservation_expiration_time_in_minutes
    (ENV["RESERVATION_EXPIRATION_TIME_IN_MINUTES"] || 15).to_i.minutes
  end
end
