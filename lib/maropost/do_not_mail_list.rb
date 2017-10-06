module Maropost
  class DoNotMailList
    def self.exists?(contact)
      response = request(:get,
                         "#{Maropost.configuration.api_url}/global_unsubscribes/email.json?contact[email]=#{contact.email}")
      JSON.parse response.body

      response['id'] ? true : false
    rescue RestClient::ResourceNotFound, RestClient::BadRequest => e
      contact.errors << "Unexpected error occurred. Error: #{e.message}"
      contact
    end

    def self.create(contact)
      payload = { "global_unsubscribe": { "email": contact.email } }

      request(:post,
              "#{Maropost.configuration.api_url}/global_unsubscribes.json",
              payload)
      contact
    rescue RestClient::UnprocessableEntity, RestClient::BadRequest => e
      contact.errors << "Unable to subscribe contact. Error: #{e.message}"
      contact
    end

    def self.delete(contact)
      request(:delete,
              "#{Maropost.configuration.api_url}/global_unsubscribes/delete.json?email=#{contact.email}")
      contact
    rescue RestClient::UnprocessableEntity, RestClient::BadRequest => e
      contact.errors << "Unable to unsubscribe contact. Error: #{e.message}"
      contact
    end

    private

    def self.request(method, url, payload = {})
      RestClient::Request.logged_request(
        method: method,
        read_timeout: 10,
        open_timeout: 5,
        url: url,
        payload: { auth_token: Maropost.configuration.auth_token }.merge(payload).to_json,
        headers: { content_type: 'application/json', accept: 'application/json' },
        verify_ssl: OpenSSL::SSL::VERIFY_PEER
      )
    end
  end
end
