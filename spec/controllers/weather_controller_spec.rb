require 'rails_helper'

RSpec.describe WeatherController, type: :request do
  let(:geocoded_data) do
    {
      latitude: 40.7128,
      longitude: -74.0060,
      zip_code: '10001',
      city: 'New York',
      state: 'New York'
    }
  end

  let(:weather_data) do
    {
      temperature: 75,
      high_temp: 80,
      low_temp: 70,
      description: 'Broken clouds',
      humidity: '65%',
      wind_speed: '10.5 mph',
      extended_forecast: [
        {
          date: 'Monday, January 1',
          high_temp: 80,
          low_temp: 70,
          description: 'Sunny',
          icon: '01d'
        }
      ]
    }
  end

  describe 'GET /' do
    it 'returns http success' do
      get '/'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /weather/forecast' do
    let(:address) { '123 Main St, New York, NY' }

    before do
      allow_any_instance_of(GeocodingService).to receive(:geocode_address).and_return(geocoded_data)
      allow_any_instance_of(WeatherService).to receive(:get_forecast).and_return(weather_data)
      allow(Address).to receive(:find_or_create_from_address).and_return(build(:address))
      allow(WeatherForecast).to receive(:find_or_create_by_zip_code).and_return(build(:weather_forecast))
    end

    context 'with valid address' do
      it 'returns http success' do
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json' }
        expect(response).to have_http_status(:success)
      end

      it 'returns weather data in JSON format' do
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['weather']).to include(
          'location' => 'New York, New York',
          'current_temp' => 75,
          'high_temp' => 80,
          'low_temp' => 70,
          'description' => 'Broken clouds'
        )
      end

      it 'calls geocoding service' do
        expect_any_instance_of(GeocodingService).to receive(:geocode_address).with(address)
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
      end

      it 'calls weather service' do
        expect_any_instance_of(WeatherService).to receive(:get_forecast).with(40.7128, -74.0060)
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
      end

      it 'stores address in database' do
        expect(Address).to receive(:find_or_create_from_address).with(address, geocoded_data)
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
      end

      it 'stores weather forecast in database' do
        expect(WeatherForecast).to receive(:find_or_create_by_zip_code).with('10001', weather_data)
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
      end

      it 'caches the weather data' do
        expect(Rails.cache).to receive(:write).with(
          "weather_forecast_123-main-st-new-york-ny",
          kind_of(Hash),
          expires_in: 30.minutes
        )
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
      end

      it 'sets cached flag to false for fresh data' do
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
        
        json_response = JSON.parse(response.body)
        expect(json_response['weather']['cached']).to be false
      end
    end

    context 'with cached data' do
      let(:cached_weather_data) do
        {
          location: 'New York, New York',
          current_temp: 75,
          high_temp: 80,
          low_temp: 70,
          description: 'Broken clouds',
          humidity: '65%',
          wind_speed: '10.5 mph',
          forecast: []
        }
      end

      before do
        allow(Rails.cache).to receive(:read).and_return(cached_weather_data)
      end

      it 'returns cached data' do
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
        
        json_response = JSON.parse(response.body)
        expect(json_response['weather']['cached']).to be true
        expect(json_response['weather']['location']).to eq('New York, New York')
      end

      it 'does not call geocoding service' do
        expect_any_instance_of(GeocodingService).not_to receive(:geocode_address)
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
      end

      it 'does not call weather service' do
        expect_any_instance_of(WeatherService).not_to receive(:get_forecast)
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
      end
    end

    context 'with blank address' do
      it 'returns error for blank address' do
        post '/weather/forecast', params: { address: '' }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to eq('Please enter an address')
      end
    end

    context 'with nil address' do
      it 'returns error for nil address' do
        post '/weather/forecast', params: { address: nil }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to eq('Please enter an address')
      end
    end

    context 'when geocoding fails' do
      before do
        allow_any_instance_of(GeocodingService).to receive(:geocode_address).and_raise(RuntimeError, 'Geocoding failed')
      end

      it 'returns error response' do
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to eq('Geocoding failed')
      end
    end

    context 'when weather service fails' do
      before do
        allow_any_instance_of(WeatherService).to receive(:get_forecast).and_raise(RuntimeError, 'Weather API failed')
      end

      it 'returns error response' do
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to eq('Weather API failed')
      end
    end
  end

  describe 'GET /weather/:id' do
    let(:weather_forecast) { create(:weather_forecast) }

    context 'when weather forecast exists' do
      it 'returns http success' do
        get "/weather/#{weather_forecast.id}", headers: { 'Host' => 'www.example.com' }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when weather forecast does not exist' do
      it 'redirects to root path' do
        get '/weather/999999', headers: { 'Host' => 'www.example.com' }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end 