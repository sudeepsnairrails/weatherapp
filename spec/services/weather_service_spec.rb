require 'rails_helper'

RSpec.describe WeatherService do
  let(:service) { WeatherService.new }
  let(:latitude) { 40.7128 }
  let(:longitude) { -74.0060 }

  describe '#get_forecast' do
    context 'when weather API call is successful' do
      let(:current_weather_response) do
        {
          'main' => {
            'temp' => 75.0,
            'temp_max' => 80.0,
            'temp_min' => 70.0
          },
          'weather' => [{ 'description' => 'Broken clouds' }]
        }
      end

      let(:forecast_response) do
        {
          'list' => [
            {
              'dt_txt' => Time.current.strftime('%Y-%m-%d %H:%M:%S'),
              'main' => { 'temp' => 75.0 },
              'weather' => [{ 'description' => 'Sunny', 'icon' => '01d' }]
            },
            {
              'dt_txt' => (Time.current + 1.day).strftime('%Y-%m-%d %H:%M:%S'),
              'main' => { 'temp' => 82.0 },
              'weather' => [{ 'description' => 'Partly cloudy', 'icon' => '02d' }]
            }
          ]
        }
      end

      before do
        allow(WeatherService).to receive(:get).and_return(
          double(
            success?: true,
            parsed_response: current_weather_response
          ),
          double(
            success?: true,
            parsed_response: forecast_response
          )
        )
      end

      it 'returns weather data' do
        result = service.get_forecast(latitude, longitude)
        
        expect(result).to include(
          temperature: 75,
          high_temp: 80,
          low_temp: 70,
          description: 'Broken clouds'
        )
      end

      it 'includes extended forecast' do
        result = service.get_forecast(latitude, longitude)
        
        expect(result[:extended_forecast]).to be_an(Array)
        expect(result[:extended_forecast].length).to eq(2)
        
        first_day = result[:extended_forecast].first
        expect(first_day).to include(
          high_temp: 82,
          low_temp: 75,
          description: 'Sunny',
          icon: '01d'
        )
      end

      it 'makes a request to OpenWeatherMap API' do
        service.get_forecast(latitude, longitude)
        
        expect(WeatherService).to have_received(:get).twice
        expect(WeatherService).to have_received(:get).with(
          '/weather',
          query: {
            lat: latitude,
            lon: longitude,
            appid: ENV['OPENWEATHER_API_KEY'],
            units: 'imperial'
          }
        )
      end
    end

    context 'when weather API call fails' do
      before do
        allow(WeatherService).to receive(:get).and_return(
          double(
            success?: false,
            parsed_response: { 'message' => 'Invalid API key' }
          )
        )
      end

      it 'raises an error' do
        expect {
          service.get_forecast(latitude, longitude)
        }.to raise_error(RuntimeError, /Weather API call failed/)
      end
    end

    context 'when API response is missing required data' do
      let(:incomplete_response) do
        {
          'main' => {
            'temp' => 75.0
            # Missing other required fields
          }
        }
      end

      before do
        allow(WeatherService).to receive(:get).and_return(
          double(
            success?: true,
            parsed_response: incomplete_response
          ),
          double(
            success?: true,
            parsed_response: { 'list' => [] }
          )
        )
      end

      it 'handles missing data gracefully' do
        expect {
          service.get_forecast(latitude, longitude)
        }.to raise_error(RuntimeError, /Unable to fetch weather data/)
      end
    end

    context 'when daily forecast is missing' do
      let(:response_without_forecast) do
        {
          'main' => {
            'temp' => 75.0,
            'temp_max' => 80.0,
            'temp_min' => 70.0
          },
          'weather' => [{ 'description' => 'Broken clouds' }]
        }
      end

      before do
        allow(WeatherService).to receive(:get).and_return(
          double(
            success?: true,
            parsed_response: response_without_forecast
          ),
          double(
            success?: true,
            parsed_response: { 'list' => [] }
          )
        )
      end

      it 'returns empty extended forecast' do
        result = service.get_forecast(latitude, longitude)
        
        expect(result[:extended_forecast]).to eq([])
      end
    end
  end
end 