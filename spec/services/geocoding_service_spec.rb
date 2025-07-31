require 'rails_helper'

RSpec.describe GeocodingService do
  let(:service) { GeocodingService.new }
  let(:address) { '123 Main St, New York, NY' }

  describe '#geocode_address' do
    context 'when geocoding is successful' do
      let(:successful_response) do
        {
          'results' => [
            {
              'geometry' => {
                'location' => {
                  'lat' => 40.7128,
                  'lng' => -74.0060
                }
              },
              'address_components' => [
                { 'types' => ['postal_code'], 'long_name' => '10001' },
                { 'types' => ['locality'], 'long_name' => 'New York' },
                { 'types' => ['administrative_area_level_1'], 'long_name' => 'New York' }
              ]
            }
          ],
          'status' => 'OK'
        }
      end

      before do
        allow(GeocodingService).to receive(:get).and_return(
          double(
            success?: true,
            parsed_response: successful_response
          )
        )
      end

      it 'returns geocoded data' do
        result = service.geocode_address(address)
        
        expect(result).to include(
          latitude: 40.7128,
          longitude: -74.0060,
          zip_code: '10001',
          city: 'New York',
          state: 'New York'
        )
      end

      it 'makes a request to Google Geocoding API' do
        service.geocode_address(address)
        
        expect(GeocodingService).to have_received(:get).with(
          '/geocode/json',
          query: {
            address: address,
            key: ENV['GOOGLE_MAPS_API_KEY']
          }
        )
      end
    end

    context 'when geocoding fails' do
      before do
        allow(GeocodingService).to receive(:get).and_return(
          double(
            success?: false,
            parsed_response: { 'status' => 'REQUEST_DENIED' }
          )
        )
      end

      it 'raises an error' do
        expect {
          service.geocode_address(address)
        }.to raise_error(RuntimeError, /Geocoding failed/)
      end
    end

    context 'when API returns no results' do
      before do
        allow(GeocodingService).to receive(:get).and_return(
          double(
            success?: true,
            parsed_response: { 'status' => 'ZERO_RESULTS' }
          )
        )
      end

      it 'raises an error' do
        expect {
          service.geocode_address(address)
        }.to raise_error(RuntimeError, /No results found/)
      end
    end

    context 'when API returns an error status' do
      before do
        allow(GeocodingService).to receive(:get).and_return(
          double(
            success?: true,
            parsed_response: { 'status' => 'INVALID_REQUEST' }
          )
        )
      end

      it 'raises an error' do
        expect {
          service.geocode_address(address)
        }.to raise_error(RuntimeError, /Geocoding failed/)
      end
    end
  end
end 