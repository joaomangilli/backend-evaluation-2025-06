class PriceToken
  class << self
    def generate(start_at:, end_at:, price:, currency:)
      payload = {
        start_at: start_at.iso8601,
        end_at: end_at.iso8601,
        price: price,
        currency: currency
      }
      encryptor.encrypt_and_sign(payload.to_json)
    end

    def decrypt(token)
      json = encryptor.decrypt_and_verify(token)
      JSON.parse(json, symbolize_names: true)
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      nil
    end

    private

    def encryptor
      key = Rails.application.secret_key_base.byteslice(0, ActiveSupport::MessageEncryptor.key_len)
      ActiveSupport::MessageEncryptor.new(key)
    end
  end
end
