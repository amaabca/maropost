require 'simplecov'
require 'rspec'
require 'webmock/rspec'
require 'maropost'

gem_dir = Gem::Specification.find_by_name('maropost').gem_dir
Dir[File.join(gem_dir, 'spec/support/**/*.rb')].each { |f| puts f; require f }

RSpec.configure do |config|
  config.include Helpers::Requests
  config.color = true
  config.tty = true
end
