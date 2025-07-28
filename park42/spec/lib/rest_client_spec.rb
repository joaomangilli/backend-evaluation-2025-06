require 'rails_helper'

RSpec.describe RestClient do
  let(:url) { 'https://api.example.com/endpoint' }
  let(:payload) { { user_id: 123, amount: 1000 } }
  let(:header) { { "Content-Type" => "application/json" } }

  let(:faraday_response) do
    double(
      'faraday_response',
      success?: faraday_response_success?,
      status: faraday_response_status,
      body: faraday_response_body
    )
  end

  let(:faraday_response_success?) { true }
  let(:faraday_response_status) { 200 }
  let(:faraday_response_body) { '{"message":"success","id":123}' }

  subject(:rest_client) { described_class.new(url: url) }

  describe '#post' do
    before do
      allow(Faraday).to(
        receive(:post).with(url, payload.to_json, header).and_return(faraday_response)
      )
    end

    let(:response) { rest_client.post(payload: payload) }

    it 'returns successful Response object' do
      expect(response.success?).to be_truthy
      expect(response.status).to eq(200)
      expect(response.body).to eq({ message: 'success', id: 123 })
    end

    context 'when invalid JSON response' do
      let(:faraday_response_body) { 'Invalid JSON content' }

      it 'returns empty hash for body' do
        expect(response.body).to eq({})
      end
    end

    context 'when Faraday raises an error' do
      let(:faraday_error) { Faraday::Error.new('Generic error') }

      before do
        allow(Faraday).to receive(:post).and_raise(faraday_error)
      end

      it 'raises RestClient::Error with the original error' do
        expect { rest_client.post(payload: payload) }.to raise_error(
          RestClient::Error,
          'Generic error'
        )
      end
    end
  end
end
