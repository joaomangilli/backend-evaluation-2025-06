require 'rails_helper'

RSpec.describe "POST /price", type: :request do
  let(:user) { User.create!(email: 'user@example.com', password: 'password') }
  let(:session) { user.sessions.create!(user_agent: 'RSpec', ip_address: '127.0.0.1') }
  let(:headers) do
    {
      'Authorization' => "Bearer #{session.token}",
      'Content-Type' => 'application/json'
    }
  end

  it 'returns the price token and price' do
    start_at = Time.utc(2025, 6, 1)
    end_at = Time.utc(2025, 6, 2)

    post '/price', params: { start_at: start_at.iso8601, end_at: end_at.iso8601 }.to_json, headers: headers

    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body, symbolize_names: true)
    expect(json[:currency]).to eq('BRL')
    expect(json[:price]).to eq(50_000)
    token_data = PriceToken.decrypt(json[:price_token])
    expect(token_data).to include(start_at: start_at.iso8601, end_at: end_at.iso8601, price: 50_000, currency: 'BRL')
  end

  it 'validates end_at after start_at' do
    start_at = Time.utc(2025, 6, 2)
    end_at = Time.utc(2025, 6, 1)

    post '/price', params: { start_at: start_at.iso8601, end_at: end_at.iso8601 }.to_json, headers: headers

    expect(response).to have_http_status(:unprocessable_entity)
    json = JSON.parse(response.body, symbolize_names: true)
    expect(json[:error]).to eq('end_at must be after start_at')
  end
end
