# frozen_string_literal: true

module Maropost
  class Api
    class << self
      def find(email)
        raise ArgumentError, 'must provide email' if email.blank?
        service = Service.new(
          method: :get,
          path: 'contacts/email.json',
          query: {
            'contact[email]': email,
            'auth_token': Maropost.configuration.auth_token
          }
        )
        response = JSON.parse(service.execute!.body)
        Maropost::Contact.new(response)
      rescue RestClient::ResourceNotFound
        nil
      end

      def update_subscriptions(contact)
        update_do_not_mail_list(contact)
        to_maropost(
          find(contact.email),
          contact
        )
      end

      def create(contact)
        service = Service.new(
          method: :post,
          path: 'contacts.json',
          payload: create_or_update_payload(contact)
        )
        response = JSON.parse(service.execute!.body)
        Maropost::Contact.new(response)
      rescue RestClient::UnprocessableEntity, RestClient::BadRequest
        contact.errors << 'Unable to create or update contact'
        contact
      end

      def update(contact)
        service = Service.new(
          method: :put,
          path: "contacts/#{contact.id}.json",
          payload: create_or_update_payload(contact)
        )
        response = JSON.parse(service.execute!.body)
        Maropost::Contact.new(response)
      rescue RestClient::UnprocessableEntity, RestClient::BadRequest
        contact.errors << 'Unable to update contact'
        contact
      end

      def change_email(old_email, new_email)
        contact = nil
        old_email_contact = find(old_email)
        new_email_contact = find(new_email)

        if old_email_contact.present? && new_email_contact.present?
          new_email_contact = new_email_contact.merge_settings(old_email_contact)
          contact = update(new_email_contact)
          Maropost::DoNotMailList.create(old_email_contact)
        elsif old_email_contact.present?
          old_email_contact.email = new_email
          contact = update(old_email_contact)
        elsif new_email_contact.present?
          contact = update(new_email_contact)
        end

        update_do_not_mail_list(contact) if contact

        contact
      end

      private

      def create_or_update_payload(contact)
        {
          contact: {
            email: contact.email,
            phone: contact.phone_number,
            custom_field: contact.list_parameters
          }
        }
      end

      def to_maropost(existing, contact)
        if existing
          contact.id = existing.id
          update(contact)
        else
          create(contact)
        end
      end

      def update_do_not_mail_list(contact)
        if contact.allow_emails?
          DoNotMailList.delete(contact)
        else
          DoNotMailList.create(contact)
        end
      end
    end
  end
end
