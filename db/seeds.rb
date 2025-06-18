# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

[
  "michael@dundermifflin.com",
  "dwight@dundermifflin.com",
  "jim@dundermifflin.com",
  "pam@dundermifflin.com",
  "angela@dundermifflin.com"
].each do |addr|
  User.find_or_create_by!(email: addr) do |u|
    u.password = "password"
  end
end
