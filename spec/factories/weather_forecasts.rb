FactoryBot.define do
  factory :weather_forecast do
    zip_code { Faker::Address.zip_code }
    temperature { rand(20..100) }
    high_temp { |forecast| (forecast.temperature || 75) + rand(5..15) }
    low_temp { |forecast| (forecast.temperature || 75) - rand(5..15) }
    description { ['Sunny', 'Cloudy', 'Rainy', 'Snowy', 'Partly Cloudy'].sample }
    extended_forecast do
      [
        {
          date: 'Monday, January 1',
          high_temp: 80,
          low_temp: 70,
          description: 'Sunny',
          icon: '01d'
        }
      ]
    end
    cached_at { Time.current }
  end
end 