require 'spec_helper'

describe Maropost::DoNotMailList do
  let(:contact) { Maropost::Contact.new(email: 'test@example.com') }

  describe 'GET #exists?' do
    subject { Maropost::DoNotMailList.exists?(contact) }
    let(:found_response) { File.read File.join('spec', 'fixtures', 'do_not_mail_list', 'do_not_mail_found.json') }
    let(:not_found_response) { File.read File.join('spec', 'fixtures', 'do_not_mail_list', 'do_not_mail_not_found.json') }

    context 'email address is found on list' do
      it 'returns true' do
        stub_do_not_mail_list_exists({ body: found_response })
        expect(subject).to be_truthy
      end
    end

    context 'email address is not found on list' do
      it 'returns false' do
        stub_do_not_mail_list_exists({ body: not_found_response })
        expect(subject).to be_falsey
      end
    end

    context 'raises exception' do
      it 'returns false' do
        stub_do_not_mail_list_exists({ status: 400 })
        expect(subject.errors).not_to be_empty
      end
    end
  end

  describe 'POST #create' do
    subject { Maropost::DoNotMailList.create(contact) }

    context 'successfully added to do not mail list' do
      it 'no errors exist' do
        stub_do_not_mail_list_create({ status: 200 })

        expect(subject.errors).to be_empty
      end
    end

    context 'raises exception' do
      it 'adds errors to contact' do
        stub_do_not_mail_list_create({ status: 422 })

        expect(subject.errors).not_to be_empty
      end
    end
  end

  describe 'DELETE #delete' do
    subject { Maropost::DoNotMailList.delete(contact) }

    context 'successfully added to do not mail list' do
      it 'no errors exist' do
        stub_do_not_mail_list_delete({status: 200})
        expect(subject.errors).to be_empty
      end
    end

    context 'raises exception' do
      it 'adds errors to contact' do
        stub_do_not_mail_list_delete({status: 422})
        expect(subject.errors).not_to be_empty
      end
    end
  end
end
