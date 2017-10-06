require 'spec_helper'

describe Maropost::Api do
  describe 'find' do
    context 'contact exists on maropost' do
      let(:maropost_contact_response) { File.read File.join('spec', 'fixtures', 'contacts', 'contact.json') }

      it 'returns maropost contact' do
        WebMock.stub_request(:get, /.*contacts\/email.json/).to_return(body: maropost_contact_response)

        contact = Maropost::Api.find(maropost_contact_response['email'])

        expected_contact = JSON.parse maropost_contact_response
        expect(contact.id).to eq expected_contact['id']
        expect(contact.email).to eq expected_contact['email']
        expect(contact.ama_rewards).to eq expected_contact['ama_rewards']
        expect(contact.ama_membership).to eq expected_contact['ama_membership']
        expect(contact.ama_insurance).to eq expected_contact['ama_insurance']
        expect(contact.ama_travel).to eq expected_contact['ama_travel']
        expect(contact.ama_new_member_series).to eq expected_contact['ama_new_member_series']
        expect(contact.ama_fleet_safety).to eq expected_contact['ama_fleet_safety']
        expect(contact.ovrr_personal).to eq expected_contact['ovrr_personal']
        expect(contact.ovrr_business).to eq expected_contact['ovrr_business']
        expect(contact.ovrr_associate).to eq expected_contact['ovrr_associate']
        expect(contact.ama_vr_reminder).to eq expected_contact['ama_vr_reminder']
        expect(contact.ama_vr_reminder_email).to eq expected_contact['ama_vr_reminder_email']
        expect(contact.ama_vr_reminder_sms).to eq expected_contact['ama_vr_reminder_sms']
        expect(contact.ama_vr_reminder_autocall).to eq expected_contact['ama_vr_reminder_autocall']
        expect(contact.phone_number).to eq expected_contact['phone']
        expect(contact.cell_phone_number).to eq expected_contact['cell_phone_number']
      end
    end

    context 'contact does not exist on maropost' do
      it 'returns nil' do
        WebMock.stub_request(:get, /.*contacts\/email.json/).to_return(status: 404)

        contact = Maropost::Api.find('test@test.com')

        expect(contact).to be_nil
      end
    end
  end

  describe 'update subscription' do
    let(:contact) { Maropost::Contact.new(id: nil, email: 'test@test.com') }
    let(:existing_contact) { Maropost::Contact.new(id: 375373, email: 'test@test.com') }

    subject { Maropost::Api.update_subscriptions(contact) }

    context 'contact exists on maropost' do
      it 'calls update' do
        expect(Maropost::Api).to receive(:find).with(contact.email).and_return(existing_contact)
        expect(Maropost::Api).to receive(:update).with(contact)
        allow(Maropost::DoNotMailList).to receive(:create).with(contact)

        subject

        expect(contact.id).to eq existing_contact.id
      end

      context 'subscribing to a list' do
        let(:contact) { Maropost::Contact.new(id: nil, email: 'test@test.com', ama_rewards: '1') }

        it 'removes from do not mail list' do
          allow(Maropost::Api).to receive(:find).with(contact.email).and_return(existing_contact)
          allow(Maropost::Api).to receive(:update).with(contact)
          expect(Maropost::DoNotMailList).to receive(:delete).with(contact)
          subject
        end
      end

      context 'unsubscribing from all lists' do
        it 'adds to do not mail list' do
          allow(Maropost::Api).to receive(:find).with(contact.email).and_return(existing_contact)
          allow(Maropost::Api).to receive(:update).with(contact)
          expect(Maropost::DoNotMailList).to receive(:create).with(contact)
          subject
        end
      end
    end

    context 'contact does not exist on maropost' do
      it 'calls create' do
        expect(Maropost::Api).to receive(:find).with(contact.email).and_return(nil)
        expect(Maropost::Api).to receive(:create).with(contact)
        allow(Maropost::DoNotMailList).to receive(:create).with(contact)

        subject
      end
    end
  end

  describe 'update' do
    let(:existing_maropost_contact) { File.read File.join('spec', 'fixtures', 'contacts', 'contact.json') }

    subject { Maropost::Api.update(Maropost::Contact.new(id: 741000000)) }

    context 'is successful' do
      it 'updates the contact in maropost' do
        WebMock.stub_request(:put, /.*contacts\/741000000.json/).to_return(body: existing_maropost_contact)
        contact = subject

        expect(contact.errors).to be_empty
      end
    end

    context 'fails' do
      it 'sets an error on contact' do
        WebMock.stub_request(:put, /.*contacts\/741000000.json/).to_return(status: 422)
        contact = subject

        expect(contact.errors).to include 'Unable to update contact'
      end
    end
  end

  describe 'create' do
    let(:new_maropost_contact) { File.read File.join('spec', 'fixtures', 'contacts', 'contact.json') }

    subject { Maropost::Api.create(Maropost::Contact.new(email: 'test@test.com')) }

    context 'is successful' do
      it 'creates the contact in maropost' do
        WebMock.stub_request(:post, /.*contacts.json/).to_return(body: new_maropost_contact)
        contact = subject

        expect(contact.errors).to be_empty
      end
    end

    context 'fails' do
      it 'sets an error on contact' do
        WebMock.stub_request(:post, /.*contacts.json/).to_return(status: 422)
        contact = subject

        expect(contact.errors).to include 'Unable to create or update contact'
      end
    end
  end
end
