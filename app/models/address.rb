class Address < ApplicationRecord
  validates :full_address, presence: true, uniqueness: true
  validates :zip_code, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :city, presence: true
  validates :state, presence: true

  has_many :weather_forecasts, primary_key: :zip_code, foreign_key: :zip_code

  def self.find_or_create_from_address(full_address, geocoded_data)
    address = find_by(full_address: full_address)
    
    if address.nil?
      address = create!(
        full_address: full_address,
        zip_code: geocoded_data[:zip_code],
        latitude: geocoded_data[:latitude],
        longitude: geocoded_data[:longitude],
        city: geocoded_data[:city],
        state: geocoded_data[:state]
      )
    end
    
    address
  end
end 