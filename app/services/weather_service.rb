class WeatherService
  include HTTParty
  
  base_uri 'https://api.openweathermap.org/data/2.5'
  
  def initialize
    @api_key = ENV['OPENWEATHER_API_KEY']
  end

  def get_forecast(latitude, longitude)
    # Get current weather
    current_response = self.class.get('/weather', {
      query: {
        lat: latitude,
        lon: longitude,
        appid: @api_key,
        units: 'imperial'
      }
    })

    # Get 5-day forecast
    forecast_response = self.class.get('/forecast', {
      query: {
        lat: latitude,
        lon: longitude,
        appid: @api_key,
        units: 'imperial'
      }
    })

    if current_response.success? && forecast_response.success?
      current_data = current_response.parsed_response
      forecast_data = forecast_response.parsed_response
      
      {
        temperature: current_data['main']['temp'].round,
        high_temp: current_data['main']['temp_max'].round,
        low_temp: current_data['main']['temp_min'].round,
        description: current_data['weather'].first['description'].capitalize,
        extended_forecast: parse_extended_forecast(forecast_data['list'])
      }
    else
      raise "Weather API failed: #{current_response.code} - #{current_response.body}"
    end
  rescue => e
    Rails.logger.error "Weather API error: #{e.message}"
    raise "Unable to fetch weather data"
  end

  private

  def parse_extended_forecast(forecast_list)
    # Group forecasts by day and get daily high/low
    daily_forecasts = forecast_list.group_by do |forecast|
      Date.parse(forecast['dt_txt'])
    end

    daily_forecasts.map do |date, forecasts|
      temps = forecasts.map { |f| f['main']['temp'] }
      weather = forecasts.first['weather'].first
      
      {
        date: date.strftime('%A, %B %d'),
        high_temp: temps.max.round,
        low_temp: temps.min.round,
        description: weather['description'].capitalize,
        icon: weather['icon']
      }
    end.first(5) # Return next 5 days
  end
end 