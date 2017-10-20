# frozen_string_literal: true

describe Maropost::DoNotMailList do
  let(:email) { 'test+001@test.com' }
  let(:contact) { Maropost::Contact.new(email: email) }

  before(:each) do
    stub_do_not_mail_list_exists(
      email: email,
      body: read_fixture('do_not_mail_list', 'do_not_mail_not_found.json')
    )
  end

  describe 'GET #exists?' do
    subject { Maropost::DoNotMailList.exists?(contact) }
    let(:found_response) { read_fixture('do_not_mail_list', 'do_not_mail_found.json') }
    let(:not_found_response) { read_fixture('do_not_mail_list', 'do_not_mail_not_found.json') }

    context 'email address is found on list' do
      it 'returns true' do
        stub_do_not_mail_list_exists(body: found_response)
        expect(subject).to be true
      end
    end

    context 'email address is not found on list' do
      it 'returns false' do
        stub_do_not_mail_list_exists(body: not_found_response)
        expect(subject).to be false
      end
    end

    context 'raises exception' do
      it 'returns false' do
        stub_do_not_mail_list_exists(status: 400)
        expect(subject).to be false
      end
    end
  end

  describe 'POST #create' do
    subject { Maropost::DoNotMailList.create(contact) }

    context 'successfully added to do not mail list' do
      it 'returns truthy' do
        stub_do_not_mail_list_create(status: 200)
        expect(subject).to be_truthy
      end
    end

    context 'raises exception' do
      it 'returns false' do
        stub_do_not_mail_list_create(status: 422)
        expect(subject).to be false
      end
    end
  end

  describe 'DELETE #delete' do
    subject { Maropost::DoNotMailList.delete(contact) }

    context 'successfully added to do not mail list' do
      it 'returns truthy' do
        stub_do_not_mail_list_delete(status: 200)
        expect(subject).to be_truthy
      end
    end

    context 'raises exception' do
      it 'returns false' do
        stub_do_not_mail_list_delete(status: 422)
        expect(subject).to be false
      end
    end
  end
end
