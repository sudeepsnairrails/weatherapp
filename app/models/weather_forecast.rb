class WeatherForecast < ApplicationRecord
  validates :zip_code, presence: true, uniqueness: true
  validates :temperature, presence: true
  validates :high_temp, presence: true
  validates :low_temp, presence: true
  validates :description, presence: true
  validates :cached_at, presence: true

  scope :recent, -> { where('cached_at > ?', 30.minutes.ago) }
  scope :expired, -> { where('cached_at <= ?', 30.minutes.ago) }

  def expired?
    cached_at <= 30.minutes.ago
  end

  def self.find_or_create_by_zip_code(zip_code, weather_data)
    forecast = find_by(zip_code: zip_code)
    
    if forecast&.expired?
      forecast.update!(
        temperature: weather_data[:temperature],
        high_temp: weather_data[:high_temp],
        low_temp: weather_data[:low_temp],
        description: weather_data[:description],
        extended_forecast: weather_data[:extended_forecast],
        cached_at: Time.current
      )
    elsif forecast.nil?
      forecast = create!(
        zip_code: zip_code,
        temperature: weather_data[:temperature],
        high_temp: weather_data[:high_temp],
        low_temp: weather_data[:low_temp],
        description: weather_data[:description],
        extended_forecast: weather_data[:extended_forecast],
        cached_at: Time.current
      )
    end
    
    forecast
  end
end 