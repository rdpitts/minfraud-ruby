require 'spec_helper'

describe Minfraud do

  describe '.configure' do
    it 'yields the Minfraud module' do
      allow(Minfraud).to receive(:has_required_configuration?).and_return(true)
      Minfraud.configure do |c|
        expect(c).to eql(Minfraud)
      end
    end

    it 'raises an exception if required fields are not set' do
      expect { Minfraud.configure { |c| true } }.to raise_exception(Minfraud::ConfigurationError)
    end
  end

  describe '.license_key' do
    let(:license_key) { 'asdf' }

    before { Minfraud.remove_class_variable(:@@license_key) if Minfraud.class_variable_defined?(:@@license_key) }

    it 'gets license key attribute set on Minfraud module' do
      Minfraud.class_variable_set(:@@license_key, license_key)
      expect(Minfraud.license_key).to eq(license_key)
    end

    it 'returns nil when license key attribute is not set' do
      expect(Minfraud.license_key).to eq(nil)
    end
  end

  describe '.license_key=' do
    let(:license_key) { 'asdf' }

    before { Minfraud.remove_class_variable(:@@license_key) if Minfraud.class_variable_defined?(:@@license_key) }

    it 'sets license key attribute on Minfraud module' do
      Minfraud.license_key = license_key
      expect(Minfraud.class_variable_get(:@@license_key)).to eq(license_key)
    end
  end

  describe '.uri' do
    it 'returns a URI::HTTPS object' do
      expect(Minfraud.uri).to be_instance_of(URI::HTTPS)
    end

    it 'returns URI::HTTPS object containing the minFraud service uri' do
      expect(Minfraud.uri('us_east').to_s).to eq('https://minfraud-us-east.maxmind.com/app/ccv2r')
      expect(Minfraud.uri('us_west').to_s).to eq('https://minfraud-us-west.maxmind.com/app/ccv2r')
      expect(Minfraud.uri('eu_west').to_s).to eq('https://minfraud-eu-west.maxmind.com/app/ccv2r')
    end

    it 'returns URI::HTTPS object containing the minFraud service uri even if the passed choice is missing or is not valid' do
      expect(Minfraud.uri.to_s).to eq('https://minfraud.maxmind.com/app/ccv2r')
    end

    it 'throws an exception if the string passed is not one of the presets and is not a valid uri' do
      expect{Minfraud.uri(:foo).to_s}.to raise_exception(ArgumentError)
    end
  end

  describe '.has_required_configuration?' do
    let(:license_key) { 'asdf' }

    before do
      Minfraud.remove_class_variable(:@@license_key) if Minfraud.class_variable_defined?(:@@license_key)
    end

    it 'returns true if license_key is set' do
      Minfraud.class_variable_set(:@@license_key, license_key)
      expect(Minfraud.has_required_configuration?).to be true
    end

    it 'returns false if license_key is not set' do
      expect(Minfraud.has_required_configuration?).to be false
    end
  end

end
