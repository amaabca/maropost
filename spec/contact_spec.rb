# frozen_string_literal: true

describe Maropost::Contact do
  let(:email) { 'test+001@test.com' }

  before(:each) do
    stub_do_not_mail_list_exists(
      email: email,
      body: read_fixture('do_not_mail_list', 'do_not_mail_not_found.json')
    )
  end

  describe 'subscribed to any lists' do
    described_class::LISTS.each do |list_name|
      context "subscribed to #{list_name}" do
        subject { Maropost::Contact.new(list_name => '1', email: email).subscribed_to_any_lists? }

        it { expect(subject).to be_truthy }
      end
    end

    context 'not subscribed to any lists' do
      it { expect(Maropost::Contact.new(email: email).subscribed_to_any_lists?).to be_falsey }
    end
  end
end
