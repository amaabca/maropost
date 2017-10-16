module Maropost
  class Api
    class << self
      def find(email)
        raise ArgumentError, 'must provide email' if email.blank?
        response = request(
          :get,
          maropost_url('contacts/email.json', "contact[email]=#{CGI.escape(email)}")
        )
        Maropost::Contact.new(JSON.parse(response.body))
      rescue RestClient::ResourceNotFound
        nil
      end

      def update_subscriptions(contact)
        if existing_contact = find(contact.email)
          contact.id = existing_contact.id
          update(contact)
        else
          create(contact)
        end
        update_do_not_mail_list(contact)
      end

      def create(contact)
        response = request(
          :post,
          maropost_url('contacts.json'),
          create_or_update_payload(contact)
        )
        Maropost::Contact.new(JSON.parse(response.body))
      rescue RestClient::UnprocessableEntity, RestClient::BadRequest => e
        contact.errors << 'Unable to create or update contact'
        contact
      end

      def update(contact)
        response = request(
          :put,
          maropost_url("contacts/#{contact.id}.json"),
          create_or_update_payload(contact)
        )
        Maropost::Contact.new(JSON.parse(response.body))
      rescue RestClient::UnprocessableEntity, RestClient::BadRequest => e
        contact.errors << 'Unable to update contact'
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

      def create_or_update_payload(contact)
        {
          contact: {
            email: contact.email,
            phone: contact.phone_number,
            custom_field: contact.list_parameters
          }
        }
      end

      def update_do_not_mail_list(contact)
        if contact.subscribed_to_any_lists?
          DoNotMailList.delete(contact)
        else
          DoNotMailList.create(contact)
        end
      end
    end
  end
end
