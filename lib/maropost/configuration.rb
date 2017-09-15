module Maropost
  attr_accessor :configuration

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_accessor :api_url, :auth_token

    def initialize
      self.api_url = "http://example.com"
      self.auth_token = "auth_token"
    end
  end
end
