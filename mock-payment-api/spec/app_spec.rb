# frozen_string_literal: true

require 'spec_helper'

describe 'GET /status' do
  it 'returns ok' do
    get '/status'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('ok')
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
    expect(yaml['paths'].keys).to include('/status')
  end
end
