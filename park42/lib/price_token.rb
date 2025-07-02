class PriceToken
  class << self
    def generate(start_at:, end_at:, price:, currency:)
      payload = {
        start_at: start_at.try(:iso8601),
        end_at: end_at.try(:iso8601),
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

    def valid?(token:, start_at:, end_at:, price:, currency:)
      decrypted = decrypt(token.to_s) || {}

      decrypted[:start_at] == start_at &&
      decrypted[:end_at] == end_at &&
      decrypted[:price] == price &&
      decrypted[:currency] == currency
    end

    private

    def encryptor
      key = Rails.application.secret_key_base.byteslice(0, ActiveSupport::MessageEncryptor.key_len)
      ActiveSupport::MessageEncryptor.new(key)
    end
  end
end
