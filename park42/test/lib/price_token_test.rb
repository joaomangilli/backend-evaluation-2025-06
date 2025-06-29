require "test_helper"

class PriceTokenTest < ActiveSupport::TestCase
  test "generates and decrypts token" do
    start_at = Time.utc(2025, 6, 1)
    end_at = Time.utc(2025, 6, 2)
    price = 50_000
    currency = "BRL"

    token = PriceToken.generate(start_at: start_at, end_at: end_at, price: price, currency: currency)
    data = PriceToken.decrypt(token)

    assert_equal({ start_at: start_at.iso8601, end_at: end_at.iso8601, price: price, currency: currency }, data)
  end
end
