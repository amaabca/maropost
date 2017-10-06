require 'spec_helper'

describe Maropost::Contact do
  describe 'subscribed to any lists' do
    [:ama_rewards, :ama_membership, :ama_insurance, :ama_travel, :ama_new_member_series, :ama_fleet_safety,
     :ama_vr_reminder, :ama_vr_reminder_email, :ama_vr_reminder_sms, :ama_vr_reminder_autocall].each do |list_name|
      context "subscribed to #{list_name}" do
        subject { Maropost::Contact.new(list_name => '1').subscribed_to_any_lists? }
        
        it { expect(subject).to be_truthy }
      end
    end

    context 'not subscribed to any lists' do
      it { expect(Maropost::Contact.new({}).subscribed_to_any_lists?).to be_falsey }
    end
  end
end
