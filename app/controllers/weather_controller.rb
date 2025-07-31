class WeatherController < ApplicationController
  def index
    # Show the weather form
  end

  def forecast
    address = params[:address]
    
    if address.blank?
      render json: { success: false, error: "Please enter an address" } and return
    end

    begin
      # Normalize address for consistent cache keys
      normalized_address = address.strip.downcase
      cache_key = "weather_forecast_#{normalized_address.parameterize}"
      
      cached_result = Rails.cache.read(cache_key)
      
      if cached_result
        weather_data = cached_result
        from_cache = true
      else
        # Geocode the address
        geocoding_service = GeocodingService.new
        geocoded_data = geocoding_service.geocode_address(address)
        
        # Get weather data
        weather_service = WeatherService.new
        weather_data = weather_service.get_forecast(geocoded_data[:latitude], geocoded_data[:longitude])
        
        # Store in database
        address_record = Address.find_or_create_from_address(address, geocoded_data)
        forecast_record = WeatherForecast.find_or_create_by_zip_code(geocoded_data[:zip_code], weather_data)
        
        # Prepare weather data
        weather_data = {
          location: "#{geocoded_data[:city]}, #{geocoded_data[:state]}",
          current_temp: weather_data[:temperature],
          high_temp: weather_data[:high_temp],
          low_temp: weather_data[:low_temp],
          description: weather_data[:description],
          humidity: weather_data[:humidity] || "N/A",
          wind_speed: weather_data[:wind_speed] || "N/A",
          forecast: weather_data[:extended_forecast] || []
        }
        
        # Store in cache
        Rails.cache.write(cache_key, weather_data, expires_in: 30.minutes)
        
        from_cache = false
      end
      
      # Add cache indicator
      weather_data[:cached] = from_cache
      
      render json: { success: true, weather: weather_data }
    rescue => e
      Rails.logger.error "Error in forecast: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.first(5).join("\n")}"
      render json: { success: false, error: e.message }
    end
  end

  def show
    @weather_forecast = WeatherForecast.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Weather forecast not found"
    redirect_to root_path
  end


end 