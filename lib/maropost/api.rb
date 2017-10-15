module Maropost
  class Api
    def self.find(email)
      response = request(:get,
                         maropost_url('contacts/email.json', "contact[email]=#{CGI::escape(email)}"))
      Maropost::Contact.new(JSON.parse response.body)
    rescue RestClient::ResourceNotFound
      nil
    end

    def self.update_subscriptions(contact)
      if existing_contact = find(contact.email)
        contact.id = existing_contact.id
        update(contact)
      else
        create(contact)
      end
      update_do_not_mail_list(contact)
    end

    def self.create(contact)
      response = request(:post,
                          maropost_url('contacts.json'),
                          create_or_update_payload(contact))
      Maropost::Contact.new(JSON.parse response.body)
    rescue RestClient::UnprocessableEntity, RestClient::BadRequest => e
      contact.errors << 'Unable to create or update contact'
      contact
    end

    def self.update(contact)
      response = request(:put,
                         maropost_url("contacts/#{contact.id}.json"),
                         create_or_update_payload(contact))
      Maropost::Contact.new(JSON.parse response.body)
    rescue RestClient::UnprocessableEntity, RestClient::BadRequest => e
      contact.errors << 'Unable to update contact'
      contact
    end

    private

    def self.maropost_url(path, query = nil)
      URI.join(Maropost.configuration.api_url, path).tap { |u| query && u.query = query }.to_s
    end

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

    def self.create_or_update_payload(contact)
      {
        contact:
          {
            email: contact.email,
            phone: contact.phone_number,
            custom_field:
              {
                ama_rewards: contact.ama_rewards,
                ama_membership: contact.ama_membership,
                ama_insurance: contact.ama_insurance,
                ama_travel: contact.ama_travel,
                ama_new_member_series: contact.ama_new_member_series,
                ama_fleet_safety: contact.ama_fleet_safety,
                ovrr_personal: contact.ovrr_personal,
                ovrr_business: contact.ovrr_business,
                ovrr_associate: contact.ovrr_associate,
                ama_vr_reminder: contact.ama_vr_reminder,
                ama_vr_reminder_email: contact.ama_vr_reminder_email,
                ama_vr_reminder_sms: contact.ama_vr_reminder_sms,
                ama_vr_reminder_autocall: contact.ama_vr_reminder_autocall,
                cell_phone_number: contact.cell_phone_number
              }
          }
      }
    end

    def self.update_do_not_mail_list(contact)
      if contact.subscribed_to_any_lists?
        DoNotMailList.delete(contact)
      else
        DoNotMailList.create(contact)
      end
    end
  end
end
