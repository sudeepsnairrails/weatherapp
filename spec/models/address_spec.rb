require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      address = build(:address)
      expect(address).to be_valid
    end

    it 'is not valid without a full_address' do
      address = build(:address, full_address: nil)
      expect(address).not_to be_valid
    end

    it 'is not valid without a zip_code' do
      address = build(:address, zip_code: nil)
      expect(address).not_to be_valid
    end

    it 'is not valid without a latitude' do
      address = build(:address, latitude: nil)
      expect(address).not_to be_valid
    end

    it 'is not valid without a longitude' do
      address = build(:address, longitude: nil)
      expect(address).not_to be_valid
    end

    it 'is not valid without a city' do
      address = build(:address, city: nil)
      expect(address).not_to be_valid
    end

    it 'is not valid without a state' do
      address = build(:address, state: nil)
      expect(address).not_to be_valid
    end

    it 'enforces unique full_address' do
      create(:address, full_address: '123 Main St, New York, NY')
      address = build(:address, full_address: '123 Main St, New York, NY')
      expect(address).not_to be_valid
    end
  end

  describe '.find_or_create_from_address' do
    let(:address_string) { '123 Main St, New York, NY' }
    let(:geocoded_data) do
      {
        latitude: 40.7128,
        longitude: -74.0060,
        zip_code: '10001',
        city: 'New York',
        state: 'New York'
      }
    end

    context 'when address does not exist' do
      it 'creates a new address record' do
        expect {
          Address.find_or_create_from_address(address_string, geocoded_data)
        }.to change(Address, :count).by(1)
      end

      it 'returns the created address' do
        address = Address.find_or_create_from_address(address_string, geocoded_data)
        expect(address.full_address).to eq(address_string)
        expect(address.latitude).to eq(40.7128)
        expect(address.longitude).to eq(-74.0060)
        expect(address.zip_code).to eq('10001')
        expect(address.city).to eq('New York')
        expect(address.state).to eq('New York')
      end
    end

    context 'when address already exists' do
      let!(:existing_address) { create(:address, full_address: address_string) }

      it 'does not create a new address record' do
        expect {
          Address.find_or_create_from_address(address_string, geocoded_data)
        }.not_to change(Address, :count)
      end

      it 'returns the existing address' do
        address = Address.find_or_create_from_address(address_string, geocoded_data)
        expect(address).to eq(existing_address)
      end
    end
  end

  describe 'associations' do
    it 'has many weather forecasts' do
      address = create(:address)
      expect(address.weather_forecasts).to be_empty
    end
  end
end 