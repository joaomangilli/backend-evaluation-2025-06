FactoryBot.define do
  factory :reservation do
    user
    price_token { SecureRandom.hex(10) }
    payment_token { SecureRandom.hex(10) }
    start_at { 1.day.from_now }
    end_at { 2.days.from_now }
    amount { 1000 }
    status { :pending }
  end
end
