# frozen_string_literal: true

describe Maropost::Contact do
  describe 'subscribed to any lists' do
    described_class::LISTS.each do |list_name|
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
