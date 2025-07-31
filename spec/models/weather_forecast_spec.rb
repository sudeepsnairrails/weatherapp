require 'rails_helper'

RSpec.describe WeatherForecast, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      forecast = build(:weather_forecast)
      expect(forecast).to be_valid
    end

    it 'is not valid without a zip_code' do
      forecast = build(:weather_forecast, zip_code: nil)
      expect(forecast).not_to be_valid
    end

    it 'is not valid without a temperature' do
      forecast = build(:weather_forecast, temperature: nil)
      expect(forecast).not_to be_valid
    end

    it 'is not valid without a high_temp' do
      forecast = build(:weather_forecast, high_temp: nil)
      expect(forecast).not_to be_valid
    end

    it 'is not valid without a low_temp' do
      forecast = build(:weather_forecast, low_temp: nil)
      expect(forecast).not_to be_valid
    end

    it 'is not valid without a description' do
      forecast = build(:weather_forecast, description: nil)
      expect(forecast).not_to be_valid
    end

    it 'is not valid without cached_at' do
      forecast = build(:weather_forecast, cached_at: nil)
      expect(forecast).not_to be_valid
    end

    it 'enforces unique zip_code' do
      create(:weather_forecast, zip_code: '12345')
      forecast = build(:weather_forecast, zip_code: '12345')
      expect(forecast).not_to be_valid
    end
  end

  describe 'scopes' do
    let!(:recent_forecast) { create(:weather_forecast, cached_at: 15.minutes.ago) }
    let!(:expired_forecast) { create(:weather_forecast, cached_at: 45.minutes.ago) }

    describe '.recent' do
      it 'returns forecasts cached within 30 minutes' do
        expect(WeatherForecast.recent).to include(recent_forecast)
        expect(WeatherForecast.recent).not_to include(expired_forecast)
      end
    end

    describe '.expired' do
      it 'returns forecasts cached more than 30 minutes ago' do
        expect(WeatherForecast.expired).to include(expired_forecast)
        expect(WeatherForecast.expired).not_to include(recent_forecast)
      end
    end
  end

  describe '#expired?' do
    it 'returns true for forecasts older than 30 minutes' do
      forecast = build(:weather_forecast, cached_at: 45.minutes.ago)
      expect(forecast.expired?).to be true
    end

    it 'returns false for forecasts newer than 30 minutes' do
      forecast = build(:weather_forecast, cached_at: 15.minutes.ago)
      expect(forecast.expired?).to be false
    end
  end

  describe '.find_or_create_by_zip_code' do
    let(:zip_code) { '12345' }
    let(:weather_data) do
      {
        temperature: 75,
        high_temp: 80,
        low_temp: 70,
        description: 'Sunny',
        extended_forecast: [{ date: 'Monday', high: 80, low: 70 }]
      }
    end

    context 'when forecast does not exist' do
      it 'creates a new forecast' do
        expect {
          WeatherForecast.find_or_create_by_zip_code(zip_code, weather_data)
        }.to change(WeatherForecast, :count).by(1)
      end

      it 'returns the created forecast' do
        forecast = WeatherForecast.find_or_create_by_zip_code(zip_code, weather_data)
        expect(forecast.zip_code).to eq(zip_code)
        expect(forecast.temperature).to eq(75)
      end
    end

    context 'when forecast exists and is expired' do
      let!(:existing_forecast) { create(:weather_forecast, zip_code: zip_code, cached_at: 45.minutes.ago) }

      it 'updates the existing forecast' do
        expect {
          WeatherForecast.find_or_create_by_zip_code(zip_code, weather_data)
        }.not_to change(WeatherForecast, :count)

        existing_forecast.reload
        expect(existing_forecast.temperature).to eq(75)
        expect(existing_forecast.cached_at).to be_within(1.second).of(Time.current)
      end
    end

    context 'when forecast exists and is not expired' do
      let!(:existing_forecast) { create(:weather_forecast, zip_code: zip_code, cached_at: 15.minutes.ago) }

      it 'returns the existing forecast without updating' do
        original_cached_at = existing_forecast.cached_at
        forecast = WeatherForecast.find_or_create_by_zip_code(zip_code, weather_data)
        
        expect(forecast).to eq(existing_forecast)
        expect(forecast.cached_at).to eq(original_cached_at)
      end
    end
  end
end 