class ApplicationController < ActionController::API
  include Authentication

  def currency
    "BRL"
  end
end
