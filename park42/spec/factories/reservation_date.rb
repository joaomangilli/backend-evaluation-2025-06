FactoryBot.define do
  factory :reservation_date do
    reservation_at { 1.day.from_now }
    reservation_count { 0 }
  end
end
