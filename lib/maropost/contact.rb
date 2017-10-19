# frozen_string_literal: true

module Maropost
  class Contact
    ATTRIBUTES = %i[
      do_not_contact
      id
      email
      phone_number
      cell_phone_number
      lists
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

    attr_accessor(*ATTRIBUTES)

    def initialize(opts = {})
      data = opts.with_indifferent_access
      self.id = data[:id]
      self.email = data[:email]
      self.phone_number = data[:phone]
      self.cell_phone_number = data[:cell_phone_number]
      self.do_not_contact = data.fetch(:do_not_contact, false)
      self.errors = []
      self.lists = {}
      initialize_lists(data)
    end

    def allow_emails?
      @allow_emails ||= email.present? && !do_not_contact && !DoNotMailList.exists?(self)
    end

    def subscribed_to_any_lists?
      lists.values.any? { |v| v == '1' }
    end

    def list_parameters
      { cell_phone_number: cell_phone_number }.merge(lists)
    end

    private

    def initialize_lists(opts = {})
      LISTS.each do |list|
        lists[list] = opts.fetch(list, 0).to_s
      end
    end
  end
end
