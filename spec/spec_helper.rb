# frozen_string_literal: true

require 'simplecov'
require 'rspec'
require 'webmock/rspec'
require 'maropost'
require 'pry'

gem_dir = Gem::Specification.find_by_name('maropost').gem_dir
Dir[File.join(gem_dir, 'spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include Helpers::Fixtures
  config.include Helpers::Requests
  config.color = true
  config.tty = true

  config.before(:each) do
    stub_do_not_mail_list_exists(body: read_fixture('do_not_mail_list', 'do_not_mail_not_found.json'))
  end
end

Maropost.configure do |config|
  config.auth_token = 'auth_token'
  config.api_url = 'https://maropost.example.com/api/123/'
end
