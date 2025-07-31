# Weather App

A modern Ruby on Rails weather application that provides real-time weather forecasts for any address. Built with Docker, featuring Redis caching, MySQL database, and comprehensive test coverage.

## 🌟 Features

### Core Functionality
- **Address-based Weather Lookup** - Enter any address to get current weather conditions
- **Real-time Weather Data** - Current temperature, high/low temperatures, humidity, wind speed
- **Extended 5-Day Forecast** - Detailed weather predictions for the upcoming week
- **Smart Caching System** - 30-minute Redis cache with visual cache indicators
- **Address Geocoding** - Automatic conversion of addresses to coordinates using Google Maps API

### User Experience
- **Modern, Responsive UI** - Clean, intuitive interface that works on all devices
- **Real-time Updates** - AJAX-powered form submission with dynamic content updates
- **Cache Indicators** - Visual feedback when data is served from cache (⚡ indicator)
- **Error Handling** - Graceful error messages for invalid addresses or API failures
- **Loading States** - Smooth loading animations during data fetching

### Technical Features
- **Docker Containerization** - Complete containerized environment with MySQL and Redis
- **Comprehensive Testing** - Full RSpec test suite with model, service, controller, and integration tests
- **API Integration** - OpenWeatherMap API for weather data, Google Maps API for geocoding
- **Database Persistence** - MySQL database for storing addresses and weather forecasts
- **Production Ready** - Optimized for deployment with proper environment configuration

## 🛠 Technologies Used

### Backend
- **Ruby 3.2.2** - Modern Ruby version for optimal performance
- **Rails 7.1.0** - Latest Rails framework with modern conventions
- **MySQL 8.0** - Robust relational database for data persistence
- **Redis 7** - High-performance caching layer for weather data
- **Puma** - Multi-threaded web server for better performance

### Frontend
- **Vanilla JavaScript** - Modern ES6+ JavaScript for dynamic interactions
- **CSS3** - Custom styling with gradients, animations, and responsive design
- **HTML5** - Semantic markup for accessibility and SEO
- **AJAX** - Asynchronous data loading for smooth user experience

### APIs & Services
- **OpenWeatherMap API** - Comprehensive weather data and forecasts
- **Google Maps Geocoding API** - Address to coordinate conversion
- **HTTParty** - Ruby HTTP client for API integrations

### Development & Testing
- **Docker & Docker Compose** - Containerized development environment
- **RSpec** - Comprehensive testing framework
- **FactoryBot** - Test data generation
- **Faker** - Realistic test data creation

### Infrastructure
- **Docker** - Application containerization
- **Docker Compose** - Multi-service orchestration
- **Environment Variables** - Secure configuration management
- **Asset Pipeline** - Optimized asset delivery

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- OpenWeatherMap API key
- Google Maps API key

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd weatherapp
   ```

2. **Create environment file**
   ```bash
   cp env.example .env
   ```

3. **Add your API keys to `.env`**
   ```bash
   OPENWEATHER_API_KEY=your_openweather_api_key_here
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
   ```

4. **Start the application**
   ```bash
   docker-compose up -d
   ```

5. **Access the application**
   - Open your browser and go to `http://localhost:3001`
   - The application will be ready in a few moments

## 📖 Usage

### Getting Weather Information
1. **Enter an address** in the input field (e.g., "123 Main St, New York, NY")
2. **Click "Get Weather"** or press Enter
3. **View the results** including:
   - Current temperature and conditions
   - High/low temperatures
   - Humidity and wind speed
   - 5-day extended forecast
   - Cache indicator (⚡) if data is served from cache

### Features in Action
- **First Request**: Data is fetched from APIs and cached for 30 minutes
- **Subsequent Requests**: Same address returns cached data instantly with cache indicator
- **Different Addresses**: Each address is cached separately
- **Error Handling**: Invalid addresses show helpful error messages

## 🧪 Testing

### Run All Tests
```bash
docker-compose exec web bundle exec rspec
```

### Run Specific Test Suites
```bash
# Model tests only
docker-compose exec web bundle exec rspec spec/models/

# Service tests only
docker-compose exec web bundle exec rspec spec/services/

# Controller tests only
docker-compose exec web bundle exec rspec spec/controllers/

# Integration tests only
docker-compose exec web bundle exec rspec spec/requests/
```

### Test Coverage
- **Model Tests**: Address and WeatherForecast validations, associations, and methods
- **Service Tests**: GeocodingService and WeatherService with mocked API responses
- **Controller Tests**: All controller actions with various scenarios
- **Integration Tests**: End-to-end workflow testing
- **Request Tests**: Full HTTP request/response cycle testing

## 🏗 Architecture

### Application Structure
```
app/
├── controllers/          # Controller logic
├── models/              # ActiveRecord models
├── services/            # Business logic services
├── views/               # ERB templates
└── assets/              # CSS, JavaScript, and images
```

### Key Components
- **WeatherController**: Handles weather requests and caching
- **GeocodingService**: Converts addresses to coordinates
- **WeatherService**: Fetches weather data from APIs
- **Address Model**: Stores address information
- **WeatherForecast Model**: Stores weather data with caching

### Data Flow
1. User enters address → Form submission via AJAX
2. Address geocoded → Google Maps API
3. Weather data fetched → OpenWeatherMap API
4. Data cached → Redis (30-minute TTL)
5. Response rendered → Dynamic HTML update

## 🔧 Configuration

### Environment Variables
- `OPENWEATHER_API_KEY`: Your OpenWeatherMap API key
- `GOOGLE_MAPS_API_KEY`: Your Google Maps API key
- `DATABASE_URL`: MySQL connection string
- `REDIS_URL`: Redis connection string

### Docker Services
- **Web**: Rails application (port 3001)
- **DB**: MySQL database (port 3307)
- **Redis**: Cache server (port 6380)

## 📊 Performance

### Caching Strategy
- **Redis Cache**: 30-minute TTL for weather data
- **Cache Keys**: Normalized by address for consistency
- **Cache Indicators**: Visual feedback for cached responses
- **Database Persistence**: Addresses and forecasts stored in MySQL

### Optimization Features
- **AJAX Requests**: Asynchronous data loading
- **Asset Optimization**: Minified CSS and JavaScript
- **Database Indexing**: Optimized queries for performance
- **Connection Pooling**: Efficient database connections

## 🚀 Deployment

### Production Considerations
- Set `RAILS_ENV=production`
- Configure production database credentials
- Set up SSL certificates
- Configure proper logging
- Set up monitoring and alerting

### Scaling Options
- **Horizontal Scaling**: Multiple web containers behind load balancer
- **Database Scaling**: Read replicas for database queries
- **Cache Scaling**: Redis cluster for high availability

