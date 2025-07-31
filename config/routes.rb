Rails.application.routes.draw do
  # Root route - main weather page
  root "weather#index"
  
  # Weather routes
  get "weather", to: "weather#index"
  post "weather/forecast", to: "weather#forecast"
  get "weather/:id", to: "weather#show"
  

end
