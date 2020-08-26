# frozen_string_literal: true

require 'otr-activerecord'
require 'rspec'
require 'rack/test'
require 'airborne'
require 'webmock/rspec'
require 'coveralls'
require 'webmock'
require 'simplecov'

Coveralls.wear!

# local coverage report
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start

WebMock.disable_net_connect!(allow_localhost: true)

ENV['RAILS_ENV'] ||= 'test'

Dir.glob(File.join(File.join(File.dirname(__FILE__), '..'), '*_api.rb')).sort.each do |file|
  require file
end

Dir.glob(File.join(File.join(File.dirname(__FILE__), '..', 'lib'), '**.rb')).sort.each do |file|
  require file
end

# configure rack
StarBus::API.before { env['api.tilt.root'] = 'rabl' }

Airborne.configure do |config|
  config.rack_app = StarBus::API.new
end

# init active-record
OTR::ActiveRecord.configure_from_file! 'config/database.yml'

# rload "db/seeds.rb"

require 'helpers'
