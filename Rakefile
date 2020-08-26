# frozen_string_literal: true

require 'yaml'
require 'bundler/setup'

require_relative 'starbus-api'
require_relative 'model/line'
require_relative 'model/stop'

require 'rspec/core/rake_task'
require 'coveralls/rake/task'

Coveralls::RakeTask.new
task test_with_coveralls: [:spec, :features, 'coveralls:push']

RSpec::Core::RakeTask.new(:spec)

load 'tasks/otr-activerecord.rake'

task default: :spec

namespace :db do
  task :environment do
    if ENV['DATABASE_URL']
      OTR::ActiveRecord.configure_from_url! ENV['DATABASE_URL']
    else
      OTR::ActiveRecord.configure_from_file! 'config/database.yml'
    end
  end
end

namespace :gp do
  desc 'Mostra todas as rotas da api.'
  task :routes do
    StarBus::API.routes.each do |api|
      method = api.request_method.ljust(10)
      path = api.path
      puts " #{method} - #{path}"
    end
  end
end
