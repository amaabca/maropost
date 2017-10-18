# frozen_string_literal: true

describe Maropost do
  it 'has a version number' do
    expect(Maropost::VERSION).not_to be nil
  end

  describe '.configure' do
    it 'yields a Maropost::Configuration instance' do
      described_class.configure do |config|
        expect(config).to be_a(Maropost::Configuration)
      end
    end
  end
end
