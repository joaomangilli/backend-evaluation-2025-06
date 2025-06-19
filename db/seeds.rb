# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

[
  "user1@example.com",
  "user2@example.com",
  "user3@example.com",
  "user4@example.com",
  "user5@example.com"
].each do |addr|
  User.find_or_create_by!(email: addr) do |u|
    u.password = "password"
  end
end
