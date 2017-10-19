# frozen_string_literal: true

describe Maropost::Api do
  describe 'find' do
    context 'contact exists on maropost' do
      let(:maropost_contact_response) { read_fixture('contacts', 'contact.json') }

      before(:each) do
        stub_find_maropost_contact(
          email: maropost_contact_response['email'],
          body: maropost_contact_response
        )
      end

      it 'returns maropost contact' do
        contact = Maropost::Api.find(maropost_contact_response['email'])
        lists = contact.lists
        expected_contact = JSON.parse maropost_contact_response
        expect(contact.id).to eq expected_contact['id']
        expect(contact.email).to eq expected_contact['email']
        expect(lists[:ama_rewards]).to eq expected_contact['ama_rewards']
        expect(lists[:ama_membership]).to eq expected_contact['ama_membership']
        expect(lists[:ama_insurance]).to eq expected_contact['ama_insurance']
        expect(lists[:ama_travel]).to eq expected_contact['ama_travel']
        expect(lists[:ama_new_member_series]).to eq expected_contact['ama_new_member_series']
        expect(lists[:ama_fleet_safety]).to eq expected_contact['ama_fleet_safety']
        expect(lists[:ovrr_personal]).to eq expected_contact['ovrr_personal']
        expect(lists[:ovrr_business]).to eq expected_contact['ovrr_business']
        expect(lists[:ovrr_associate]).to eq expected_contact['ovrr_associate']
        expect(lists[:ama_vr_reminder]).to eq expected_contact['ama_vr_reminder']
        expect(lists[:ama_vr_reminder_email]).to eq expected_contact['ama_vr_reminder_email']
        expect(lists[:ama_vr_reminder_sms]).to eq expected_contact['ama_vr_reminder_sms']
        expect(lists[:ama_vr_reminder_autocall]).to eq expected_contact['ama_vr_reminder_autocall']
        expect(contact.phone_number).to eq expected_contact['phone']
        expect(contact.cell_phone_number).to eq expected_contact['cell_phone_number']
      end
    end

    context 'contact does not exist on maropost' do
      let(:email) { 'test@test.com' }
      it 'returns nil' do
        stub_find_maropost_contact(email: email, status: 404)

        contact = Maropost::Api.find(email)

        expect(contact).to be_nil
      end
    end
  end

  describe 'update subscription' do
    let(:contact) { Maropost::Contact.new(id: nil, email: 'test@test.com') }
    let(:existing_contact) { Maropost::Contact.new(id: 741_000_000, email: 'test@test.com') }

    subject { Maropost::Api.update_subscriptions(contact) }

    before(:each) do
      stub_find_maropost_contact(email: contact.email)
      stub_update_maropost_contact(contact_id: existing_contact.id)
      stub_do_not_mail_list_exists(
        email: 'test@test.com',
        body: read_fixture('do_not_mail_list', 'do_not_mail_not_found.json')
      )
    end

    context 'contact exists on maropost' do
      it 'calls update' do
        stub_do_not_mail_list_create
        subject
        expect(contact.id).to eq existing_contact.id
      end

      context 'subscribing to a list' do
        let(:contact) { Maropost::Contact.new(id: nil, email: 'test@test.com', ama_rewards: '1') }

        it 'removes from do not mail list' do
          expect(Maropost::DoNotMailList).to receive(:delete).with(contact)
          subject
        end
      end

      context 'explicitly opting into the do not mail list' do
        let(:contact) { Maropost::Contact.new(id: nil, email: 'test@test.com', ama_rewards: '1', do_not_contact: true) }

        before(:each) do
          stub_do_not_mail_list_create
        end

        it 'adds to do not mail list' do
          expect(Maropost::DoNotMailList).to receive(:create).with(contact)
          subject
        end
      end

      context 'unsubscribing from all lists' do
        it 'adds to do not mail list' do
          expect(Maropost::DoNotMailList).to receive(:create).with(contact)
          subject
        end
      end
    end

    context 'contact does not exist on maropost' do
      it 'calls create' do
        expect(Maropost::Api).to receive(:find).with(contact.email).and_return(nil)
        expect(Maropost::Api).to receive(:create).with(contact)
        stub_do_not_mail_list_create
        subject
      end
    end
  end

  describe 'update' do
    subject { Maropost::Api.update(Maropost::Contact.new(id: 741_000_000)) }

    context 'is successful' do
      it 'updates the contact in maropost' do
        stub_update_maropost_contact(contact_id: 741_000_000)
        expect(subject.errors).to be_empty
      end
    end

    context 'fails' do
      it 'sets an error on contact' do
        stub_update_maropost_contact(contact_id: 741_000_000, status: 422)
        expect(subject.errors).to include 'Unable to update contact'
      end
    end
  end

  describe 'create' do
    subject { Maropost::Api.create(Maropost::Contact.new(email: 'test@test.com')) }

    context 'is successful' do
      it 'creates the contact in maropost' do
        stub_create_maropost_contact
        expect(subject.errors).to be_empty
      end
    end

    context 'fails' do
      it 'sets an error on contact' do
        stub_create_maropost_contact(status: 422)
        expect(subject.errors).to include 'Unable to create or update contact'
      end
    end
  end
end
