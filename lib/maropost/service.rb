# frozen_string_literal: true

module Maropost
  class Service
    attr_accessor :method, :path, :query, :payload, :request_id

    def initialize(opts = {})
      self.method = opts.fetch(:method)
      self.path = opts.fetch(:path)
      self.payload = opts.fetch(:payload, {}) # optional
      self.query = opts[:query] # optional
      self.request_id = SecureRandom.uuid
    end

    def execute!
      RestClient::Request.logged_request(params)
    end

    private

    def maropost_url
      self.query &&= encode_query(query)
      uri = URI.join(Maropost.configuration.api_url, path)
      uri.tap { |u| query && u.query = query }.to_s
    end

    def encode_query(hash)
      RestClient::Utils.encode_query_string(hash)
    end

    def get?
      method.to_s.casecmp('get').zero?
    end

    def base_params
      {
        method: method,
        read_timeout: Maropost.configuration.read_timeout,
        open_timeout: Maropost.configuration.open_timeout,
        url: maropost_url,
        headers: {
          content_type: 'application/json',
          accept: 'application/json',
          request_id: request_id
        },
        verify_ssl: OpenSSL::SSL::VERIFY_PEER
      }
    end

    def params
      return base_params if get?
      base_params.merge(
        payload: { auth_token: Maropost.configuration.auth_token }.merge(payload).to_json
      )
    end
  end
end
