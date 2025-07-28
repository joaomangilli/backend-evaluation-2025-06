class RestClient
  class Response < Struct.new(:success?, :status, :body); end
  class Error < StandardError; end

  attr_reader :url

  def initialize(url:)
    @url = url
  end

  def self.post(url:, payload:)
    new(url:).post(payload:)
  end

  def post(payload:)
    response = Faraday.post(url, payload.to_json, { "Content-Type" => "application/json" })

    body = begin
      JSON.parse(response.body).deep_symbolize_keys
    rescue JSON::ParserError
      {}
    end

    Response.new(
      response.success?,
      response.status,
      body
    )
  rescue Faraday::Error => e
    raise Error, e
  end
end
