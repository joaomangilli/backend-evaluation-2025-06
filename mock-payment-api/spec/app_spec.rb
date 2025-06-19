# frozen_string_literal: true

require 'spec_helper'
require 'openssl'

describe 'GET /status' do
  it 'returns ok' do
    get '/status'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('ok')
  end
end

describe 'POST /payment-tokens' do
  let(:params) do
    {
      card_number: '4111111111111111',
      expiration: '12/25',
      cvv: '123'
    }.to_json
  end

  it 'returns a payment token' do
    post '/payment-tokens', params, { 'CONTENT_TYPE' => 'application/json' }
    expect(last_response.status).to eq(200)
    json = JSON.parse(last_response.body)
    expected_token = OpenSSL::HMAC.hexdigest('SHA256', 'secret_key', params)
    expect(json).to eq('payment_token' => expected_token)
  end

  it 'returns 422 when params are invalid' do
    invalid_params = { card_number: '123', expiration: '13/25', cvv: '12' }.to_json
    post '/payment-tokens', invalid_params, { 'CONTENT_TYPE' => 'application/json' }
    expect(last_response.status).to eq(422)
    json = JSON.parse(last_response.body)
    expect(json['errors']).to include('card_number must be digits', 'expiration must be in MM/YY format', 'cvv must be 3 or 4 digits')
  end

  it 'returns 400 for invalid JSON' do
    post '/payment-tokens', 'not-json', { 'CONTENT_TYPE' => 'application/json' }
    expect(last_response.status).to eq(400)
    json = JSON.parse(last_response.body)
    expect(json['errors']).to include('invalid JSON')
  end
end

describe 'GET /api-docs' do
  it 'redirects to the Swagger UI index' do
    get '/api-docs'
    expect(last_response.status).to eq(301)
    follow_redirect!
    expect(last_request.path).to eq('/api-docs/index.html')
  end
end

describe 'GET /api-docs/v1/swagger.yaml' do
  it 'serves the openapi file' do
    get '/api-docs/v1/swagger.yaml'
    expect(last_response.status).to eq(200)
    yaml = YAML.safe_load(last_response.body)
    expect(yaml['paths'].keys).to include('/status', '/payment-tokens')
  end
end
