class PricesController < ApplicationController
  DAILY_FEE = 2_500

  def create
    params.require(%i[start_at end_at])
    start_at = Time.zone.parse(params[:start_at])
    end_at = Time.zone.parse(params[:end_at])

    total_days = (end_at.to_date - start_at.to_date).to_i
    if total_days.negative?
      total_days = 0
    else
      total_days += 1
    end
    total_price = total_days * DAILY_FEE

    render json: { price: total_price, currency: "BRL" }
  end
end
