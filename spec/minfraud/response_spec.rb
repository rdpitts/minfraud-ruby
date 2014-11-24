require 'spec_helper'

describe Minfraud::Response do
  let(:ok_response_double) { double(Net::HTTPOK, body: 'firstKey=first value;second_keyName=second value', is_a?: true, code: 200) }
  let(:test_response_double) { double(Net::HTTPOK, body: 'distance=17034;ip_latitude=-27.0000', is_a?: true, code: 200) }
  let(:boolean_test_response_double) { double(Net::HTTPOK, body: 'countryMatch=Yes;highRiskCountry=No;binMatch=NotFound;binNameMatch=NA', is_a?: true, code: 200) }
  let(:warning_response_double) { double(Net::HTTPOK, body: 'err=COUNTRY_NOT_FOUND', is_a?: true, code: 200) }
  let(:error_response_double) { double(Net::HTTPOK, body: 'err=INVALID_LICENSE_KEY', is_a?: true, code: 200) }
  let(:server_error_response_double) { double(Net::HTTPRequestTimeOut, code: 408) }
  let(:err) { Faker::HipsterIpsum.word }

  describe '.new' do
    subject(:response) { Minfraud::Response.new(ok_response_double).tap {|r| r.parse} }
    subject(:test_response) { Minfraud::Response.new(test_response_double).tap {|r| r.parse} }
    subject(:boolean_test_response) { Minfraud::Response.new(boolean_test_response_double).tap {|r| r.parse} }
    subject(:server_error_response) { Minfraud::Response.new(server_error_response_double) }
    subject(:error_response) { Minfraud::Response.new(error_response_double) }
    subject(:warning_response) { Minfraud::Response.new(warning_response_double) }

    it 'parse raises exception without an OK response' do
      expect { server_error_response.parse }.to raise_exception(Minfraud::ConnectionException)
    end

    it 'parse raises exception if minFraud returns an error' do
      expect { error_response.parse }.to raise_exception(Minfraud::ResponseError, /INVALID_LICENSE_KEY/)
    end

    it 'parse does not raise an exception if minFraud returns a warning' do
      expect { warning_response.parse }.not_to raise_exception
    end

    it 'turns raw body keys and values into attributes on the object' do
      expect(response.first_key).to eq('first value')
      expect(response.second_key_name).to eq('second value')
    end

    it 'returns response code' do
      expect(response.code).to eq(200)
      expect(server_error_response.code).to eq(408)
    end

    it 'transforms integer and float attributes to relevant integer and float values' do
      expect(test_response.distance).to eq(17034)
      expect(test_response.distance).to be_an(Integer)

      expect(test_response.ip_latitude).to eq(-27)
      expect(test_response.ip_latitude).to be_a(Float)
    end

    it 'transforms boolean attributes to relevant boolean values' do
      expect(boolean_test_response.country_match).to be true
      expect(boolean_test_response.high_risk_country).to be false
      expect(boolean_test_response.bin_match).to be_nil
      expect(boolean_test_response.bin_name_match).to be_nil
    end
  end

end
