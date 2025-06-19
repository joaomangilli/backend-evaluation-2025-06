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
    raw_body = request.body.read
    begin
      payload = JSON.parse(raw_body)
    rescue JSON::ParserError
      status 400
      content_type :json
      return({ errors: [ 'invalid JSON' ] }.to_json)
    end

    errors = []
    card_number = payload['card_number']
    expiration = payload['expiration']
    cvv = payload['cvv']

    errors << 'card_number is required' unless card_number
    errors << 'expiration is required' unless expiration
    errors << 'cvv is required' unless cvv

    if card_number && card_number !~ /^\d{13,19}$/
      errors << 'card_number must be digits'
    end

    if expiration && expiration !~ %r{\A(0[1-9]|1[0-2])\/\d{2}\z}
      errors << 'expiration must be in MM/YY format'
    end

    if cvv && cvv !~ /^\d{3,4}$/
      errors << 'cvv must be 3 or 4 digits'
    end

    unless errors.empty?
      status 422
      content_type :json
      return({ errors: errors }.to_json)
    end

    token = OpenSSL::HMAC.hexdigest('SHA256', 'secret_key', payload.to_json)
    content_type :json
    { payment_token: token }.to_json
  end
end

MockPaymentAPI.run! if $PROGRAM_NAME == __FILE__
