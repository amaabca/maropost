# frozen_string_literal: true

describe Maropost::Service do
  describe '#execute!' do
    context 'with a payload' do
      subject do
        described_class.new(
          method: method,
          path: 'test.json',
          payload: { foo: 'bar' }
        )
      end

      context 'with a get request' do
        let(:method) { :get }

        before(:each) do
          stub_request(:get, /test/)
            .with(body: nil)
            .to_return(
              status: 200,
              body: '{"success":true}'
            )
        end

        it 'ignores the payload' do
          expect(subject.execute!.code).to eq(200)
        end
      end

      context 'with a non-get request' do
        let(:method) { :post }

        before(:each) do
          stub_request(:post, /test/)
            .with(body: '{"auth_token":"auth_token","foo":"bar"}')
            .to_return(
              status: 200,
              body: '{"success":true}'
            )
        end

        it 'sends the payload to the api' do
          expect(subject.execute!.code).to eq(200)
        end
      end

      context 'with a query' do
        subject do
          described_class.new(
            method: :get,
            path: 'test.json',
            query: {
              'contact[test]+01': true
            }
          )
        end

        before(:each) do
          stub_request(:get, /\?contact%5Btest%2B01%5D=true/)
            .with(body: nil)
            .to_return(
              status: 200,
              body: '{"success":true}'
            )
        end

        it 'url encodes the query parameters' do
          expect(subject.execute!.code).to eq(200)
        end
      end
    end
  end
end
