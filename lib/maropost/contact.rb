# frozen_string_literal: true

module Maropost
  class Contact
    ATTRIBUTES = %i[
      allow_emails
      id
      email
      phone_number
      first_name
      last_name
      cell_phone_number
      lists
      custom_attributes
      errors
    ].freeze
    LISTS = %i[
      ama_rewards
      ama_membership
      ama_insurance
      ama_travel
      ama_new_member_series
      ama_fleet_safety
      ovrr_personal
      ovrr_business
      ovrr_associate
      ama_vr_reminder
      ama_vr_reminder_email
      ama_vr_reminder_sms
      ama_vr_reminder_autocall
    ].freeze
    CUSTOM_ATTRIBUTES = %i[
      postal_code
      address_lines
      city
      birthdate
      province
    ].freeze

    attr_accessor(*ATTRIBUTES)

    def initialize(opts = {})
      data = opts.with_indifferent_access
      self.id = data[:id]
      self.email = data[:email]
      self.phone_number = data[:phone] || data[:phone_number]
      self.first_name = data[:first_name]
      self.last_name = data[:last_name]
      self.cell_phone_number = data[:cell_phone_number]
      self.allow_emails = data.fetch(:allow_emails) { !DoNotMailList.exists?(self) }
      self.errors = []
      initialize_lists(data)
      initialize_custom_attributes(data)
    end

    def allow_emails?
      allow_emails
    end

    def subscribed_to_any_lists?
      lists.values.any? { |v| v == '1' }
    end

    def list_parameters
      { cell_phone_number: cell_phone_number }.merge(lists)
    end

    def custom_parameters
      list_parameters.merge(custom_attributes)
    end

    def merge_settings(old_contact)
      self.phone_number = old_contact.phone_number
      self.cell_phone_number = old_contact.cell_phone_number
      self.allow_emails = old_contact.allow_emails

      lists.each do |list|
        lists[list] == '1' ? list : old_contact.lists[list]
      end

      self
    end

    private

    def initialize_lists(opts = {})
      self.lists = {}
      LISTS.each do |list|
        lists[list] = opts.fetch(list, 0).to_s
      end
    end

    def initialize_custom_attributes(opts = {})
      self.custom_attributes = {}
      CUSTOM_ATTRIBUTES.each do |custom_attribute|
        custom_attributes[custom_attribute] = opts.fetch(custom_attribute, 0).to_s
      end
    end
  end
end
