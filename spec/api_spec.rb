# frozen_string_literal: true

describe Maropost::Api do
  let(:email) { 'test+001@test.com' }

  before(:each) do
    stub_do_not_mail_list_exists(
      email: email,
      body: read_fixture('do_not_mail_list', 'do_not_mail_not_found.json')
    )
  end

  describe 'find' do
    context 'contact exists on maropost' do
      let(:maropost_contact_response) { read_fixture('contacts', 'contact.json') }

      before(:each) do
        stub_find_maropost_contact(
          email: email,
          body: maropost_contact_response
        )
      end

      it 'returns maropost contact' do
        contact = Maropost::Api.find(email)
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
      it 'returns nil' do
        stub_find_maropost_contact(email: email, status: 404)

        contact = Maropost::Api.find(email)

        expect(contact).to be_nil
      end
    end
  end

  describe 'update subscription' do
    let(:contact) { Maropost::Contact.new(id: nil, email: email) }
    let(:existing_contact) { Maropost::Contact.new(id: 741_000_000, email: email) }

    subject { Maropost::Api.update_subscriptions(contact) }

    before(:each) do
      stub_find_maropost_contact(email: contact.email)
      stub_update_maropost_contact(contact_id: existing_contact.id)
    end

    context 'contact exists on maropost' do
      it 'calls update' do
        stub_do_not_mail_list_delete
        subject
        expect(contact.id).to eq existing_contact.id
      end

      context 'subscribing to a list' do
        let(:contact) { Maropost::Contact.new(id: nil, email: email, ama_rewards: '1') }

        it 'removes from do not mail list' do
          expect(Maropost::DoNotMailList).to receive(:delete).with(contact)
          subject
        end
      end

      context 'explicitly opting into the do not mail list' do
        let(:contact) { Maropost::Contact.new(id: nil, email: email, ama_rewards: '1', allow_emails: false) }

        before(:each) do
          stub_do_not_mail_list_create
        end

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
        stub_do_not_mail_list_delete
        subject
      end
    end
  end

  describe 'update' do
    subject { Maropost::Api.update(Maropost::Contact.new(id: 741_000_000, email: email)) }

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

  describe 'creates with first name and last name' do
    subject { Maropost::Api.create(Maropost::Contact.new(email: email, first_name: 'Homer', last_name: 'Simpson')) }

    context 'is successful' do
      it 'creates the contact in maropost' do
        stub_create_maropost_contact
        expect(subject.errors).to be_empty
      end
    end
  end

  describe 'create' do
    subject { Maropost::Api.create(Maropost::Contact.new(email: email)) }

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

  describe 'change email' do
    let(:existing_contact_maropost_response) { read_fixture('contacts', 'other_existing_contact.json') }
    let(:old_contact_maropost_response) { read_fixture('contacts', 'contact.json') }

    let(:old_email) { 'test+001@test.com' }
    let(:new_email) { 'test@example.com' }

    subject { Maropost::Api.change_email(old_email, new_email) }

    context 'contact does not exist in maropost with the new email' do
      context 'maropost contact exists with old email' do
        let(:email_updated_contact) { read_fixture('contacts', 'email_updated_contact.json') }

        let(:new_email) { 'updated_email@example.com' }

        before do
          stub_find_maropost_contact(email: old_email, status: 200)
          stub_find_maropost_contact(email: new_email, status: 404)
          stub_do_not_mail_list_exists(email: old_email, status: 404)
          stub_do_not_mail_list_exists(email: new_email, status: 404)
          stub_update_maropost_contact(contact_id: 741_000_000, status: 200, body: email_updated_contact)
          stub_do_not_mail_list_delete(email: new_email)
        end

        it 'returns updated contact' do
          contact = subject

          expect(contact.email).to eq new_email
        end
      end

      context 'maropost contact does not exist with old email' do
        let(:old_email) { 'non_existent_user@example.com' }
        let(:new_email) { 'new_non_existent_user@example.com' }

        before do
          stub_find_maropost_contact(email: old_email, status: 404, body: '{"message": "Contact is not present!"}')
          stub_find_maropost_contact(email: new_email, status: 404, body: '{"message": "Contact is not present!"}')
        end

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
    end

    context 'contact exists in maropost with the new email' do
      context 'maropost contact exists with old email' do
        let(:merged_contact_maropost_response) { read_fixture('contacts', 'merged_contact.json') }

        before do
          stub_find_maropost_contact(email: old_email, status: 200, body: old_contact_maropost_response)
          stub_find_maropost_contact(email: new_email, status: 200, body: existing_contact_maropost_response)
          stub_do_not_mail_list_exists(email: old_email, status: 404)
          stub_do_not_mail_list_exists(email: new_email, status: 404)
          stub_update_maropost_contact(contact_id: 888_000_000, status: 200, body: merged_contact_maropost_response)
          stub_do_not_mail_list_delete(email: new_email)
          stub_do_not_mail_list_create(email: old_email)
        end

        it 'applies old maropost contact settings to existing maropost contact' do
          updated_contact = subject
          lists = updated_contact.lists

          merged_contact = JSON.parse merged_contact_maropost_response

          expect(updated_contact.id).to eq merged_contact['id']
          expect(updated_contact.email).to eq new_email
          expect(updated_contact.phone_number).to eq merged_contact['phone']
          expect(updated_contact.cell_phone_number).to eq merged_contact['cell_phone_number']
          expect(updated_contact.allow_emails).to be_truthy

          expect(lists[:ama_rewards]).to eq merged_contact['ama_rewards']
          expect(lists[:ama_membership]).to eq merged_contact['ama_membership']
          expect(lists[:ama_insurance]).to eq merged_contact['ama_insurance']
          expect(lists[:ama_travel]).to eq merged_contact['ama_travel']
          expect(lists[:ama_new_member_series]).to eq merged_contact['ama_new_member_series']
          expect(lists[:ama_fleet_safety]).to eq merged_contact['ama_fleet_safety']
          expect(lists[:ovrr_personal]).to eq merged_contact['ovrr_personal']
          expect(lists[:ovrr_business]).to eq merged_contact['ovrr_business']
          expect(lists[:ovrr_associate]).to eq merged_contact['ovrr_associate']
          expect(lists[:ama_vr_reminder]).to eq merged_contact['ama_vr_reminder']
          expect(lists[:ama_vr_reminder_email]).to eq merged_contact['ama_vr_reminder_email']
          expect(lists[:ama_vr_reminder_sms]).to eq merged_contact['ama_vr_reminder_sms']
          expect(lists[:ama_vr_reminder_autocall]).to eq merged_contact['ama_vr_reminder_autocall']
        end
      end

      context 'maropost contact does not exist with old email' do
        before do
          stub_find_maropost_contact(email: old_email, status: 404, body: '{"message": "Contact is not present!"}')
          stub_find_maropost_contact(email: new_email, status: 200, body: existing_contact_maropost_response)
          stub_do_not_mail_list_exists(email: new_email, status: 404)
          stub_update_maropost_contact(contact_id: 888_000_000, status: 200, body: existing_contact_maropost_response)
          stub_do_not_mail_list_delete(email: new_email)
        end

        it 'returns new email contact' do
          contact = subject
          lists = contact.lists

          existing_contact = JSON.parse existing_contact_maropost_response

          expect(contact.id).to eq existing_contact['id']
          expect(contact.email).to eq new_email
          expect(contact.phone_number).to eq existing_contact['phone']
          expect(contact.cell_phone_number).to eq existing_contact['cell_phone_number']
          expect(contact.allow_emails).to be_truthy

          expect(lists[:ama_rewards]).to eq existing_contact['ama_rewards']
          expect(lists[:ama_membership]).to eq existing_contact['ama_membership']
          expect(lists[:ama_insurance]).to eq existing_contact['ama_insurance']
          expect(lists[:ama_travel]).to eq existing_contact['ama_travel']
          expect(lists[:ama_new_member_series]).to eq existing_contact['ama_new_member_series']
          expect(lists[:ama_fleet_safety]).to eq existing_contact['ama_fleet_safety']
          expect(lists[:ovrr_personal]).to eq existing_contact['ovrr_personal']
          expect(lists[:ovrr_business]).to eq existing_contact['ovrr_business']
          expect(lists[:ovrr_associate]).to eq existing_contact['ovrr_associate']
          expect(lists[:ama_vr_reminder]).to eq existing_contact['ama_vr_reminder']
          expect(lists[:ama_vr_reminder_email]).to eq existing_contact['ama_vr_reminder_email']
          expect(lists[:ama_vr_reminder_sms]).to eq existing_contact['ama_vr_reminder_sms']
          expect(lists[:ama_vr_reminder_autocall]).to eq existing_contact['ama_vr_reminder_autocall']
        end
      end
    end
  end
end
