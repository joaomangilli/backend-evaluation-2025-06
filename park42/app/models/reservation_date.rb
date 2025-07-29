class ReservationDate < ApplicationRecord
  validates :reservation_at, presence: true
  validates :reservation_count, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: :max_spots
  }

  private

  def max_spots
    (ENV["MAX_SPOTS"] || 5000).to_i
  end
end
