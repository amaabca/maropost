# frozen_string_literal: true

module Maropost
  class DoNotMailList
    class << self
      def exists?(contact)
        service = Service.new(
          method: :get,
          path: 'global_unsubscribes/email.json',
          query: {
            'contact[email]': contact.email,
            'auth_token': Maropost.configuration.auth_token
          }
        )
        response = JSON.parse(service.execute!.body)
        response['id'].present?
      rescue RestClient::Exception
        false
      end

      def create(contact)
        payload = { 'global_unsubscribe': { 'email': contact.email } }
        service = Service.new(
          method: :post,
          path: 'global_unsubscribes.json',
          payload: payload
        )
        service.execute!
      rescue RestClient::Exception
        false
      end

      def delete(contact)
        service = Service.new(
          method: :delete,
          path: 'global_unsubscribes/delete.json',
          query: {
            'email': contact.email
          }
        )
        service.execute!
      rescue RestClient::Exception
        false
      end
    end
  end
end
