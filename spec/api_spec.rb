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
        expect(contact.personal_vehicle_reminder).to eq expected_contact['personal_vehicle_reminder']
        expect(contact.business_vehicle_reminder).to eq expected_contact['business_vehicle_reminder']
        expect(contact.associate_vehicle_reminder).to eq expected_contact['associate_vehicle_reminder']
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

        subject

        expect(contact.id).to eq existing_contact.id
      end
    end

    context 'contact does not exist on maropost' do
      it 'calls create' do
        expect(Maropost::Api).to receive(:find).with(contact.email).and_return(nil)
        expect(Maropost::Api).to receive(:create).with(contact)

        subject
      end
    end
  end

  describe 'update' do
    context 'is successful' do

    end

    context 'fails' do

    end
  end

  describe 'create' do
    context 'is successful' do

    end

    context 'fails' do

    end
  end
end
