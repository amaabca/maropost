require 'spec_helper'

describe Maropost::DoNotMailList do
  let(:contact) { Maropost::Contact.new(email: 'test@example.com') }

  describe 'GET #exists?' do
    subject { Maropost::DoNotMailList.exists?(contact) }

    context 'email address is found on list' do
      let(:found_response) { File.read File.join('spec', 'fixtures', 'do_not_mail_list', 'do_not_mail_found.json') }

      it 'returns true' do
        WebMock.stub_request(:get, /.*global_unsubscribes\/email.json/).to_return(body: found_response)

        expect(subject).to be_truthy
      end
    end

    context 'email address is not found on list' do
      let(:not_found_response) { File.read File.join('spec', 'fixtures', 'do_not_mail_list', 'do_not_mail_not_found.json') }

      it 'returns true' do
        WebMock.stub_request(:get, /.*global_unsubscribes\/email.json/).to_return(body: not_found_response)

        expect(subject).to be_falsey
      end
    end

    context 'raises exception' do
      let(:not_found_response) { File.read File.join('spec', 'fixtures', 'do_not_mail_list', 'do_not_mail_not_found.json') }

      it 'returns true' do
        WebMock.stub_request(:get, /.*global_unsubscribes\/email.json/).to_return(status: 500)

        expect(subject.errors).not_to be_empty
      end
    end
  end

  describe 'POST #create' do
    subject { Maropost::DoNotMailList.create(contact) }

    context 'successfully added to do not mail list' do
      it 'no errors exist' do
        WebMock.stub_request(:post, /.*global_unsubscribes/).to_return(status: 200)

        expect(subject.errors).to be_empty
      end
    end

    context 'raises exception' do
      it 'adds errors to contact' do
        WebMock.stub_request(:post, /.*global_unsubscribes/).to_return(status: 500)

        expect(subject.errors).not_to be_empty
      end
    end
  end

  describe 'DELETE #delete' do
    subject { Maropost::DoNotMailList.delete(contact) }

    context 'successfully added to do not mail list' do
      it 'no errors exist' do
        WebMock.stub_request(:delete, /.*global_unsubscribes\/delete/).to_return(status: 200)

        expect(subject.errors).to be_empty
      end
    end

    context 'raises exception' do
      it 'adds errors to contact' do
        WebMock.stub_request(:delete, /.*global_unsubscribes\/delete/).to_return(status: 500)

        expect(subject.errors).not_to be_empty
      end
    end
  end
end
