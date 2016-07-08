require 'active_model'

module Maropost
  class Contact
    include ActiveModel::Model

    attr_accessor :id, :email,
      :travel_weekly, :enews, :travel_especials, :ins_enews, :deals_discounts, :new_member_series, :fleet_contact,
      :personal_vehicle_reminder, :business_vehicle_reminder, :associate_vehicle_reminder,
      :vr_reminder_email, :vr_reminder_sms, :vr_reminder_autocall

    def self.find(email)
      response = Maropost::Api.new(data: { email: email }).find
      contact = JSON.parse response
      build contact
    rescue RestClient::ResourceNotFound => e
      new(email: email).tap do |contact|
        contact.errors.add :base, "Email not found"
      end
    end

    def create_or_update
      api = Maropost::Api.new(data: contact_data)
      response = exists? ? api.update : api.create
      contact = JSON.parse response
      self.class.build contact
    rescue RestClient::UnprocessableEntity => e
      self.tap do |contact|
        contact.errors.add :base, "Unable to create or update contact"
      end
    end

    def update_email(new_email)
      response = Maropost::Api.new(data: { email: new_email, id: id }).update_email
      contact = JSON.parse response
      self.class.build contact
    rescue RestClient::UnprocessableEntity => e
      self.tap do |contact|
        contact.errors.add :base, "Unable to update email to #{new_email}"
      end
    end

  private

    def exists?
      contact = self.class.find(email)
      contact.errors.blank?
    end

    def self.build(contact)
      new(
        id: contact["id"],
        email: contact["email"],
        travel_weekly: contact["ama_travel_weekly"] || "0",
        enews: contact["ama_enews"] || "0",
        travel_especials: contact["ama_travel_especials"] || "0",
        ins_enews: contact["ama_insurance_enews"] || "0",
        deals_discounts: contact["ama_deals_discounts"] || "0",
        new_member_series: contact["new_member_series"] || "0",
        fleet_contact: contact["ama_fleet_news"] || "0",
        personal_vehicle_reminder: contact["personal_vehicle_reminder"] || "",
        business_vehicle_reminder: contact["business_vehicle_reminder"] || "",
        associate_vehicle_reminder: contact["associate_vehicle_reminder"] || "",
        vr_reminder_email: contact["ama_vr_reminder_email"] || "0",
        vr_reminder_sms: contact["ama_vr_reminder_sms"] || "0",
        vr_reminder_autocall: contact["ama_vr_reminder_autocall"] || "0"
      )
    end

    def contact_data
      {
        id: id,
        email: email,
        ama_deals_discounts: deals_discounts,
        ama_enews: enews,
        ama_travel_especials: travel_especials,
        ama_travel_weekly: travel_weekly,
        ama_insurance_enews: ins_enews,
        ama_fleet_news: fleet_contact,
        new_member_series: new_member_series,
        personal_vehicle_reminder: personal_vehicle_reminder,
        associate_vehicle_reminder: associate_vehicle_reminder,
        business_vehicle_reminder: business_vehicle_reminder,
        ama_vr_reminder_autocall: vr_reminder_autocall,
        ama_vr_reminder_email: vr_reminder_email,
        ama_vr_reminder_sms: vr_reminder_sms
      }
    end

  end
end
