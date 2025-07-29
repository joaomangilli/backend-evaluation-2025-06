class Webhooks::BaseController < ActionController::API
  before_action :require_authentication

  def require_authentication
    head :unauthorized if request.headers["X-Webhook-Secret"] != ENV["PAYMENT_WEBHOOK_SECRET"]
  end
end
