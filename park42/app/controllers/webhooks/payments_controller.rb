class Webhooks::PaymentsController < Webhooks::BaseController
  def create
    UpdateReservationStatusJob.perform_async(
      reservation_params[:reservation_id],
      reservation_params[:status]
    )

    render json: {}, status: :ok
  end

  private

  def reservation_params
    params.permit(:reservation_id, :status)
  end
end
