module Maropost
  class DoNotMailList
    class << self
      def exists?(contact)
        response = request(
          :get,
          maropost_url('global_unsubscribes/email.json', "contact[email]=#{CGI.escape(contact.email)}")
        )
        JSON.parse(response.body)
        response['id'].present?
      rescue RestClient::ResourceNotFound, RestClient::BadRequest => e
        contact.errors << "Unexpected error occurred. Error: #{e.message}"
        contact
      end

      def create(contact)
        payload = { 'global_unsubscribe': { 'email': contact.email } }
        request(
          :post,
          maropost_url('global_unsubscribes.json'),
          payload
        )
        contact
      rescue RestClient::UnprocessableEntity, RestClient::BadRequest => e
        contact.errors << "Unable to subscribe contact. Error: #{e.message}"
        contact
      end

      def delete(contact)
        request(
          :delete,
          maropost_url('global_unsubscribes/delete.json', "email=#{CGI.escape(contact.email)}")
        )
        contact
      rescue RestClient::UnprocessableEntity, RestClient::BadRequest => e
        contact.errors << "Unable to unsubscribe contact. Error: #{e.message}"
        contact
      end

      private

      def maropost_url(path, query = nil)
        uri = URI.join(Maropost.configuration.api_url, path)
        uri.tap { |u| query && u.query = query }.to_s
      end

      def request(method, url, payload = {})
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
end
