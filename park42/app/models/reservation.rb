class Reservation < ApplicationRecord
  belongs_to :user

  validates :price_token, :payment_token, :status, presence: true
  validates :start_at, comparison: {
    greater_than_or_equal_to: Date.current,
    less_than: :reservation_end_time
  }
  validates :end_at, comparison: {
    greater_than_or_equal_to: :start_at,
    less_than: :reservation_end_time
  }, if: -> { start_at.present? }
  validates :amount, numericality: { greater_than: 0 }

  enum :status, [ :pending, :confirmed, :failed, :expired ]

  private

  def reservation_end_time
    (ENV["MAX_RESERVATION_DURATION_IN_DAYS"] || 90).to_i.days.from_now
  end
end
