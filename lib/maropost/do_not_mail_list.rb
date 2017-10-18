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
      rescue RestClient::ResourceNotFound, RestClient::BadRequest => e
        contact.errors << "Unexpected error occurred. Error: #{e.message}"
        contact
      end

      def create(contact)
        payload = { 'global_unsubscribe': { 'email': contact.email } }
        service = Service.new(
          method: :post,
          path: 'global_unsubscribes.json',
          payload: payload
        )
        service.execute!
        contact
      rescue RestClient::UnprocessableEntity, RestClient::BadRequest => e
        contact.errors << "Unable to subscribe contact. Error: #{e.message}"
        contact
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
        contact
      rescue RestClient::UnprocessableEntity, RestClient::BadRequest => e
        contact.errors << "Unable to unsubscribe contact. Error: #{e.message}"
        contact
      end
    end
  end
end
