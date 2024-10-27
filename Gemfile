# frozen_string_literal: true

source 'https://rubygems.org'

# Utilities and Utilities
gem 'figaro', '~> 1.2'
gem 'pry', '~> 0.14.2'
gem 'rake'

# Web Application
gem 'logger', '~> 1.6'
gem 'puma', '~> 6.4'
gem 'roda', '~> 3.85'
gem 'slim', '~> 5.2'

# Data Validation
gem 'dry-struct', '~> 1.6'
gem 'dry-types', '~> 1.7'

# Network dependency
gem 'http'

# Database
gem 'hirb', '~> 0.7.3'
gem 'sequel', '~> 5.85'

group :development, :test do
  gem 'sqlite3', '~> 2.1'
end

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'rerun', '~> 0.14.0'
  gem 'simplecov', '~> 0.22.0'
  gem 'vcr', '~> 6.3'
  gem 'webmock', '~> 3.24'
end

# Code Quality
group :development do
  gem 'flog', '~> 4.8'
  gem 'reek', '~> 6.3'
  gem 'rubocop', '~> 1.66'
end
