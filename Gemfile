# frozen_string_literal: true

source "https://rubygems.org"

# A simple DSL to easily develop RESTful APIs.
gem "grape"

# Adapter Postgres Ruby
gem "pg"

# Load variables in config/env.yml in ENV (variavel de ambiente).
gem "envyable"

# cliente da api da strans.
gem "strans-client"

# database lib
gem "otr-activerecord"

# json templates
gem "grape-rabl"

# time lib
gem "timerizer"

# Gem para cryptografia
gem "bcrypt"

# basic lib
gem "rake"

# Auth with jwt
gem "jwt"

# cors app
gem "rack-cors"

group :development do
  gem "coveralls", require: false
  gem "debase"
  gem "rubocop", require: false
  gem "ruby-debug-ide"
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-test'
end

group :test do
  # basic lib
  gem "rspec"
  # Mock Requests. https://github.com/bblimke/webmock
  gem "webmock"
  # teste para web apis https://github.com/brooklynDev/airborne
  gem "airborne"
  # report coverage
  gem 'simplecov'
end
