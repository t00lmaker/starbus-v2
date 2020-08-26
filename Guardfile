# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

guard 'rspec', cmd: 'bundle exec rspec' do
  watch(/starbus-api.rb/) do |_m|
    'spec/integration'
  end

  # watch /lib/ files
  watch(%r{^lib/(.+).rb$}) do |m|
    "spec/unit/#{m[1]}_spec.rb"
  end

  # watch /spec/ files
  watch(%r{^spec/(.+).rb$}) do |_m|
    'spec/'
  end
end
