// Simple JavaScript for Weather App
document.addEventListener('DOMContentLoaded', function() {
  // Form submission handling
  function handleFormSubmit(e) {
    e.preventDefault();
    
    const addressInput = document.getElementById('address');
    const address = addressInput.value.trim();
    
    if (!address) {
      showError('Please enter an address');
      return;
    }
    
    // Show loading state
    showLoading();
    
    // Submit form via AJAX
    fetch('/weather/forecast', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ address: address })
    })
    .then(response => response.json())
    .then(data => {
      console.log('Received data:', data); // Debug logging
      if (data.success) {
        console.log('Weather data cached:', data.weather.cached); // Debug logging
        displayWeather(data.weather);
      } else {
        showError(data.error || 'Failed to get weather data');
      }
    })
    .catch(error => {
      console.error('Error:', error);
      showError('An error occurred while fetching weather data');
    });
  }
  
  // Helper functions
  function showLoading() {
    const main = document.querySelector('main');
    main.innerHTML = '<div class="loading">Loading weather data...</div>';
  }
  
  function showError(message) {
    const main = document.querySelector('main');
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error';
    errorDiv.textContent = message;
    
    // Add back button
    const backButton = document.createElement('button');
    backButton.className = 'btn';
    backButton.textContent = 'Try Again';
    backButton.onclick = () => window.location.reload();
    
    errorDiv.appendChild(backButton);
    main.innerHTML = '';
    main.appendChild(errorDiv);
  }
  
  function displayWeather(weather) {
    const main = document.querySelector('main');
    
    console.log('Displaying weather, cached:', weather.cached); // Debug logging
    
    let html = `
      <div class="weather-form">
        <form id="weather-form">
          <div class="form-group">
            <label for="address">Enter Address:</label>
            <input type="text" id="address" name="address" placeholder="e.g., 123 Main St, New York, NY" required>
          </div>
          <button type="submit" class="btn">Get Weather</button>
        </form>
      </div>
    `;
    
    if (weather.cached) {
      html += `
        <div class="cache-indicator">
          ⚡ Data served from cache (30-minute cache)
        </div>
      `;
      console.log('Added cache indicator to HTML'); // Debug logging
    } else {
      console.log('Not cached, not adding indicator'); // Debug logging
    }
    
    html += `
      <div class="weather-card">
        <div class="weather-header">
          <div class="weather-location">${weather.location}</div>
          <div class="weather-temp">${weather.current_temp}°F</div>
        </div>
        <div class="weather-description">${weather.description}</div>
        
        <div class="weather-details">
          <div class="weather-detail">
            <div class="weather-detail-label">High</div>
            <div class="weather-detail-value">${weather.high_temp}°F</div>
          </div>
          <div class="weather-detail">
            <div class="weather-detail-label">Low</div>
            <div class="weather-detail-value">${weather.low_temp}°F</div>
          </div>
          <div class="weather-detail">
            <div class="weather-detail-label">Humidity</div>
            <div class="weather-detail-value">${weather.humidity}</div>
          </div>
          <div class="weather-detail">
            <div class="weather-detail-label">Wind</div>
            <div class="weather-detail-value">${weather.wind_speed}</div>
          </div>
        </div>
      </div>
    `;
    
    if (weather.forecast && weather.forecast.length > 0) {
      html += '<h3>Extended Forecast</h3>';
      html += '<div class="forecast-container">';
      
      weather.forecast.forEach(day => {
        html += `
          <div class="forecast-day">
            <div class="forecast-date">${day.date}</div>
            <div class="forecast-temp">${day.high_temp}°F / ${day.low_temp}°F</div>
            <div class="forecast-description">${day.description}</div>
          </div>
        `;
      });
      
      html += '</div>';
    }
    
    main.innerHTML = html;
    
    // Re-attach event listener to the new form
    const newForm = document.getElementById('weather-form');
    if (newForm) {
      newForm.addEventListener('submit', handleFormSubmit);
    }
  }
  
  // Initial form setup
  const weatherForm = document.getElementById('weather-form');
  if (weatherForm) {
    weatherForm.addEventListener('submit', handleFormSubmit);
  }
  
  // Add some nice animations
  const weatherCards = document.querySelectorAll('.weather-card');
  weatherCards.forEach((card, index) => {
    card.style.animationDelay = `${index * 0.1}s`;
    card.classList.add('fade-in');
  });
});

// Add CSS for fade-in animation
const style = document.createElement('style');
style.textContent = `
  .fade-in {
    animation: fadeIn 0.5s ease-in forwards;
    opacity: 0;
  }
  
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
  }
  
  .forecast-container {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    margin-top: 1rem;
  }
  
  .forecast-day {
    background: rgba(255, 255, 255, 0.1);
    padding: 1rem;
    border-radius: 8px;
    text-align: center;
  }
  
  .forecast-date {
    font-weight: bold;
    margin-bottom: 0.5rem;
  }
  
  .forecast-temp {
    font-size: 1.2rem;
    margin-bottom: 0.5rem;
  }
  
  .forecast-description {
    font-size: 0.9rem;
    opacity: 0.8;
  }
`;
document.head.appendChild(style); 