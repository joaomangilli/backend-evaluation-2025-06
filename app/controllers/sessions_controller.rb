class SessionsController < ApplicationController
  allow_unauthenticated_access only: :create
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { render json: { error: "Try again later." }, status: :too_many_requests }

  def create
    if (user = User.authenticate_by(params.permit(:email, :password)))
      session = start_new_session_for(user)
      render json: { token: session.token }, status: :created
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

end
