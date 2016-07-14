module Maropost
  class Api
    include ActiveModel::Model

    attr_accessor :url, :http_method, :data, :template_name

    def create
      self.url = "#{Maropost.configuration.api_url}/contacts.json"
      self.http_method = :post
      self.template_name = "create_or_update.json.erb"
      request
    end

    def find
      self.url = "#{Maropost.configuration.api_url}/contacts/email.json?contact[email]=#{data[:email]}"
      self.http_method = :get
      self.template_name = "find.json.erb"
      request
    end

    def update
      self.url = "#{Maropost.configuration.api_url}/contacts/#{data[:id]}.json"
      self.http_method = :put
      self.template_name = "create_or_update.json.erb"
      request
    end

    def update_email
      self.url = "#{Maropost.configuration.api_url}/contacts/#{data[:id]}.json"
      self.http_method = :put
      self.template_name = "update_email.json.erb"
      request
    end

  private
    def request
      RestClient::Request.execute(
        method: http_method,
        timeout: 10,
        open_timeout: 10,
        url: url,
        payload: payload,
        headers: { content_type: "application/json", accept: "application/json" },
        verify_ssl: OpenSSL::SSL::VERIFY_NONE
      )
    end

    def payload
      ERB.new(
        File.read(template_path).to_s
      ).result(binding)
    end

    def template_path
      File.join File.dirname(__FILE__), "templates", "contact", template_name
    end
  end
end
