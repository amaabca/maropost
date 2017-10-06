module Maropost
  class Contact
    attr_accessor :id, :email,
                  :ama_rewards, :ama_membership, :ama_insurance, :ama_travel, :ama_new_member_series, :ama_fleet_safety,
                  :ovrr_personal, :ovrr_business, :ovrr_associate,
                  :ama_vr_reminder, :ama_vr_reminder_email, :ama_vr_reminder_sms, :ama_vr_reminder_autocall,
                  :phone_number, :cell_phone_number, :errors

    def initialize(data)
      data = data.stringify_keys
      self.id = data['id']
      self.email = data['email']
      self.ama_rewards = data['ama_rewards'] || '0'
      self.ama_membership = data['ama_membership'] || '0'
      self.ama_insurance = data['ama_insurance'] || '0'
      self.ama_travel = data['ama_travel'] || '0'
      self.ama_new_member_series = data['ama_new_member_series'] || '0'
      self.ama_fleet_safety = data['ama_fleet_safety'] || '0'
      self.ovrr_personal = data['ovrr_personal'] || ''
      self.ovrr_business = data['ovrr_business'] || ''
      self.ovrr_associate = data['ovrr_associate'] || ''
      self.ama_vr_reminder = data['ama_vr_reminder'] || '0'
      self.ama_vr_reminder_email = data['ama_vr_reminder_email'] || '0'
      self.ama_vr_reminder_sms = data['ama_vr_reminder_sms'] || '0'
      self.ama_vr_reminder_autocall = data['ama_vr_reminder_autocall'] || '0'
      self.phone_number = data['phone'] || ''
      self.cell_phone_number = data['cell_phone_number'] || ''

      self.errors = []
    end

    def subscribed_to_any_lists?
      ama_rewards.eql?('1') || ama_membership.eql?('1') || ama_insurance.eql?('1') || ama_travel.eql?('1') ||
        ama_new_member_series.eql?('1') || ama_fleet_safety.eql?('1') ||
        ovrr_personal.eql?('1') || ovrr_business.eql?('1') || ovrr_associate.eql?('1') ||
        ama_vr_reminder.eql?('1') || ama_vr_reminder_email.eql?('1') || ama_vr_reminder_sms.eql?('1') ||
        ama_vr_reminder_autocall.eql?('1')
    end
  end
end
