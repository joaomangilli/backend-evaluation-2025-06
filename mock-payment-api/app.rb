# frozen_string_literal: true

require 'sinatra/base'

# Simple Sinatra application to emulate a payment service
class MockPaymentAPI < Sinatra::Base
  disable :protection

  set :port, 4000


  get '/status' do
    'ok'
  end
end

MockPaymentAPI.run! if $PROGRAM_NAME == __FILE__
