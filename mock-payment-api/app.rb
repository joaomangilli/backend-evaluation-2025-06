# frozen_string_literal: true

require 'sinatra/base'
require 'openssl'

# Simple Sinatra application to emulate a payment service
class MockPaymentAPI < Sinatra::Base
  disable :protection

  set :port, 4000


  get '/status' do
    'ok'
  end

  post '/payment-tokens' do
    body = request.body.read
    token = OpenSSL::HMAC.hexdigest('SHA256', 'secret_key', body)
    content_type :json
    { payment_token: token }.to_json
  end
end

MockPaymentAPI.run! if $PROGRAM_NAME == __FILE__
