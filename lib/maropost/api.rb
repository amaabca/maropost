module Maropost
  class Api
    def self.find(email)
      url = "#{Maropost.configuration.api_url}/contacts/email.json?contact[email]=#{email}"

      response = RestClient::Request.execute(
        method: :get,
        timeout: 10,
        open_timeout: 10,
        url: url,
        payload: { auth_token: Maropost.configuration.auth_token }.to_json,
        headers: { content_type: 'application/json', accept: 'application/json' },
        verify_ssl: OpenSSL::SSL::VERIFY_NONE
      )
      Maropost::Contact.new(JSON.parse response.body)
    rescue RestClient::NotFound
      nil
    end

    def self.update_subscriptions(contact)
      if existing_contact = find(contact.email)
        contact.id = existing_contact.id
        update(contact)
      else
        create(contact)
      end
    end

    def self.create(contact)
      url = "#{Maropost.configuration.api_url}/contacts.json"

      payload = create_or_update_payload(contact)

      response = RestClient::Request.execute(
        method: :post,
        timeout: 10,
        open_timeout: 10,
        url: url,
        payload: payload.to_json,
        headers: { content_type: 'application/json', accept: 'application/json' },
        verify_ssl: OpenSSL::SSL::VERIFY_NONE
      )
      Maropost::Contact.new(JSON.parse response.body)
    end

    def self.update(contact)
      url = "#{Maropost.configuration.api_url}/contacts/#{contact.id}.json"

      payload = create_or_update_payload(contact)

      response = RestClient::Request.execute(
        method: :put,
        timeout: 10,
        open_timeout: 10,
        url: url,
        payload: payload.to_json,
        headers: { content_type: 'application/json', accept: 'application/json' },
        verify_ssl: OpenSSL::SSL::VERIFY_NONE
      )
      Maropost::Contact.new(JSON.parse response.body)
    end

    private

    def self.create_or_update_payload(contact)
      { auth_token: Maropost.configuration.auth_token,
        contact: { email: contact.email,
                   custom_field: {
                     ama_rewards: contact.ama_rewards,
                     ama_membership: contact.ama_membership,
                     ama_insurance: contact.ama_insurance,
                     ama_travel: contact.ama_travel,
                     ama_new_member_series: contact.ama_new_member_series,
                     ama_fleet_safety: contact.ama_fleet_safety,
                     personal_vehicle_reminder: contact.personal_vehicle_reminder,
                     business_vehicle_reminder: contact.business_vehicle_reminder,
                     associate_vehicle_reminder: contact.associate_vehicle_reminder,
                     ama_vr_reminder: contact.ama_vr_reminder,
                     ama_vr_reminder_email: contact.vr_reminder_email,
                     ama_vr_reminder_sms: contact.vr_reminder_sms,
                     ama_vr_reminder_autocall: contact.vr_reminder_autocall,
                     cell_phone_number: contact.cell_phone_number,
                     phone: contact.phone_number
                   }
        }
      }
    end
  end
end
