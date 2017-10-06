module Maropost
  class DoNotMailList
    def self.exists?(contact)
      response = request(:get,
                         "#{Maropost.configuration.api_url}/global_unsubscribes/email.json?contact[email]=#{contact.email}")
      JSON.parse response.body

      response['id'].present? ? true : false
    rescue RestClient::ResourceNotFound, RestClient::BadRequest, RestClient::InternalServerError => e
      contact.errors << 'Unexpected error occured'
      contact
    end

    def self.create(contact)
      payload = { "global_unsubscribe": { "email": contact.email } }

      request(:post,
              "#{Maropost.configuration.api_url}/global_unsubscribes.json",
              payload)
      contact
    rescue RestClient::UnprocessableEntity, RestClient::BadRequest, RestClient::InternalServerError => e
      contact.errors << 'Unable to unsubscribe contact'
      contact
    end

    def self.delete(contact)
      request(:delete,
              "#{Maropost.configuration.api_url}/global_unsubscribes/delete.json?email=#{contact.email}")
      contact
    rescue RestClient::UnprocessableEntity, RestClient::BadRequest, RestClient::InternalServerError => e
      contact.errors << 'Unable to subscribe contact'
      contact
    end

    private

    def self.request(method, url, payload = {})
      RestClient::Request.logged_request(
        method: method,
        timeout: 10,
        open_timeout: 10,
        url: url,
        payload: { auth_token: Maropost.configuration.auth_token }.merge(payload).to_json,
        headers: { content_type: 'application/json', accept: 'application/json' },
        verify_ssl: OpenSSL::SSL::VERIFY_PEER
      )
    end
  end
end
