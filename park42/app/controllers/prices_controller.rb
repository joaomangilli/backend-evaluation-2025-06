class PricesController < ApplicationController
  DAILY_FEE = 25_000

  def create
    start_at_str = params.require(:start_at)
    end_at_str = params.require(:end_at)

    start_at = parse_iso8601(start_at_str)
    end_at = parse_iso8601(end_at_str)

    unless start_at
      return render json: { error: "start_at must be a valid ISO 8601 timestamp" },
                    status: :unprocessable_entity
    end

    unless end_at
      return render json: { error: "end_at must be a valid ISO 8601 timestamp" },
                    status: :unprocessable_entity
    end

    if end_at < start_at
      return render json: { error: "end_at must be after start_at" }, status: :unprocessable_entity
    end

    total_days = (end_at.to_date - start_at.to_date).to_i + 1
    total_price = total_days * DAILY_FEE
    currency = "BRL"
    price_token = PriceToken.generate(
      start_at: start_at,
      end_at: end_at,
      price: total_price,
      currency: currency
    )

    render json: { price_token: price_token, price: total_price, currency: currency }
  end

  private

  def parse_iso8601(value)
    Time.iso8601(value)
  rescue ArgumentError
    nil
  end
end
