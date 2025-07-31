class GeocodingService
  include HTTParty
  
  base_uri 'https://maps.googleapis.com/maps/api'
  
  def initialize
    @api_key = ENV['GOOGLE_MAPS_API_KEY']
  end

  def geocode_address(address)
    response = self.class.get('/geocode/json', {
      query: {
        address: address,
        key: @api_key
      }
    })

    if response.success? && response['status'] == 'OK'
      result = response['results'].first
      location = result['geometry']['location']
      address_components = result['address_components']
      
      {
        latitude: location['lat'],
        longitude: location['lng'],
        zip_code: extract_zip_code(address_components),
        city: extract_city(address_components),
        state: extract_state(address_components)
      }
    else
      raise "Geocoding failed: #{response['status']} - #{response['error_message']}"
    end
  rescue => e
    Rails.logger.error "Geocoding error: #{e.message}"
    raise "Unable to geocode address: #{address}"
  end

  private

  def extract_zip_code(components)
    zip_component = components.find { |c| c['types'].include?('postal_code') }
    zip_component&.dig('long_name')
  end

  def extract_city(components)
    city_component = components.find { |c| c['types'].include?('locality') }
    city_component&.dig('long_name')
  end

  def extract_state(components)
    state_component = components.find { |c| c['types'].include?('administrative_area_level_1') }
    state_component&.dig('long_name')
  end
end 