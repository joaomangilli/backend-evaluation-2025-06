class CreateReservationService
  class Error < StandardError; end

  attr_reader :user, :price_token, :payment_token, :start_at, :end_at, :amount, :currency

  def self.create!(user:, price_token:, payment_token:, start_at:, end_at:, amount:, currency:)
    new(user:, price_token:, payment_token:, start_at:, end_at:, amount:, currency:).create!
  end

  def initialize(user:, price_token:, payment_token:, start_at:, end_at:, amount:, currency:)
    @user = user
    @price_token = price_token
    @payment_token = payment_token
    @start_at = start_at
    @end_at = end_at
    @amount = amount
    @currency = currency
  end

  def create!
    return reservation if reservation.present?

    raise Error, "Invalid price token" unless valid_price_token?

    ActiveRecord::Base.transaction do
      begin
        create_reservation
      rescue ActiveRecord::RecordNotUnique
        return reservation
      end

      ReservationDatesService.create!(
        start_at: reservation.start_at,
        end_at: reservation.end_at
      )
    end

    CreatePaymentJob.perform_async(payment_token, amount, reservation.id)

    reservation
  end

  private

  def reservation
    @reservation ||= Reservation.find_by(price_token:, payment_token:, user:)
  end

  def create_reservation
    @reservation ||= Reservation.create!(
      user:,
      price_token:,
      payment_token:,
      start_at:,
      end_at:,
      amount:,
      status: :pending
    )
  rescue ActiveRecord::RecordInvalid => e
    raise Error, e.record.errors.full_messages.join(", ")
  end

  def valid_price_token?
    PriceToken.valid?(token: price_token, start_at:, end_at:, price: amount, currency:)
  end
end
