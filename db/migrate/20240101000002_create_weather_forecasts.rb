class CreateWeatherForecasts < ActiveRecord::Migration[7.0]
  def change
    create_table :weather_forecasts do |t|
      t.string :zip_code, null: false
      t.integer :temperature, null: false
      t.integer :high_temp, null: false
      t.integer :low_temp, null: false
      t.string :description, null: false
      t.json :extended_forecast
      t.datetime :cached_at, null: false

      t.timestamps
    end

    add_index :weather_forecasts, :zip_code, unique: true
    add_index :weather_forecasts, :cached_at
  end
end 