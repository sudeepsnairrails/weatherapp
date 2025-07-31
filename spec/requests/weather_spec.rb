require 'rails_helper'

RSpec.describe 'Weather', type: :request do
  let(:address) { '123 Main St, New York, NY' }
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

  before do
    allow_any_instance_of(GeocodingService).to receive(:geocode_address).and_return(geocoded_data)
    allow_any_instance_of(WeatherService).to receive(:get_forecast).and_return(weather_data)
  end

  describe 'GET /' do
    it 'returns the main page' do
      get '/', headers: { 'Host' => 'www.example.com' }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Enter Address')
    end
  end

  describe 'POST /weather/forecast' do
    context 'with valid address' do
      it 'returns weather data' do
        post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
        
        expect(response).to have_http_status(:success)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['weather']['location']).to eq('New York, New York')
        expect(json_response['weather']['current_temp']).to eq(75)
      end

      it 'creates address record' do
        expect {
          post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
        }.to change(Address, :count).by(1)
      end

      it 'creates weather forecast record' do
        expect {
          post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
        }.to change(WeatherForecast, :count).by(1)
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
      end

      it 'does not create new records' do
        expect {
          post '/weather/forecast', params: { address: address }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
        }.not_to change(Address, :count)
      end
    end

    context 'with invalid address' do
      it 'returns error for blank address' do
        post '/weather/forecast', params: { address: '' }, headers: { 'Content-Type' => 'application/json', 'Host' => 'www.example.com' }
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to eq('Please enter an address')
      end
    end
  end

  describe 'GET /weather/:id' do
    let(:weather_forecast) { create(:weather_forecast) }

    it 'returns weather forecast page' do
      get "/weather/#{weather_forecast.id}", headers: { 'Host' => 'www.example.com' }
      expect(response).to have_http_status(:success)
    end

    it 'returns 404 for non-existent forecast' do
      get '/weather/999999', headers: { 'Host' => 'www.example.com' }
      expect(response).to redirect_to(root_path)
    end
  end
end 