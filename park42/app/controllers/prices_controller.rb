class PricesController < ApplicationController
  DAILY_FEE = 25_000

  def create
    params.require(%i[start_at end_at])
    start_at = Time.zone.parse(params[:start_at])
    end_at = Time.zone.parse(params[:end_at])

    if end_at < start_at
      return render json: { error: "end_at must be after start_at" }, status: :unprocessable_entity
    end

    total_days = (end_at.to_date - start_at.to_date).to_i + 1
    total_price = total_days * DAILY_FEE

    render json: { price: total_price, currency: "BRL" }
  end
end
