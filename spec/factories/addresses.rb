FactoryBot.define do
  factory :address do
    full_address { Faker::Address.full_address }
    zip_code { Faker::Address.zip_code }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    city { Faker::Address.city }
    state { Faker::Address.state }
  end
end 