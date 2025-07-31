source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Rails framework
gem "rails", "~> 7.1.0"
# Database
gem "mysql2", "~> 0.5.5"
# Redis for caching
gem "redis", "~> 4.8"
# HTTP client for API calls
gem "httparty", "~> 0.21.0"
# Environment variables
gem "dotenv-rails", "~> 2.8"
# Asset pipeline
gem "sprockets-rails"
# Web server
gem "puma", "~> 6.0"

group :development, :test do
  # RSpec for testing
  gem "rspec-rails", "~> 4.1"
  gem "factory_bot_rails", "~> 6.2"
  gem "faker", "~> 2.20"
end

group :development do
  # Use console on exceptions pages
  gem "web-console", ">= 4.1.0"
  # Display performance information
  gem "rack-mini-profiler", "~> 2.0"
  gem "listen", "~> 3.3"
  # Spring speeds up development
  gem "spring"
end

# Windows does not include zoneinfo files
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1"
  gem "tzinfo-data"
end

# Reduces boot times through caching
gem "bootsnap", require: false
