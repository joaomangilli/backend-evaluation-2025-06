class ReservationsController < ApplicationController
  rescue_from CreateReservationService::Error, with: :errors
  rescue_from ReservationDatesService::Error, with: :errors

  def create
    reservation = CreateReservationService.create!(
      user: Current.session.user,
      price_token: reservation_params[:price_token],
      payment_token: reservation_params[:payment_token],
      start_at: reservation_params[:start_at],
      end_at: reservation_params[:end_at],
      amount: reservation_params[:amount],
      currency:
    )

    render json: reservation, status: :created
  end

  private

  def reservation_params
    params.permit(:price_token, :payment_token, :start_at, :end_at, :amount)
  end

  def errors(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end
end
