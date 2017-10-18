# frozen_string_literal: true

module Maropost
  attr_accessor :configuration

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_accessor :api_url, :auth_token, :open_timeout, :read_timeout

    def open_timeout
      @open_timeout || 5
    end

    def read_timeout
      @read_timeout || 10
    end
  end
end
