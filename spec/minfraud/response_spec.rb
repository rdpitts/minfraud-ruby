require 'spec_helper'

describe Minfraud::Response do
  let(:ok_response_double) { double(Net::HTTPOK, body: 'firstKey=first value;second_keyName=second value', is_a?: true, code: 200) }
  let(:test_response_double) { double(Net::HTTPOK, body: 'distance=17034;ip_latitude=-27.0000', is_a?: true, code: 200) }
  let(:boolean_test_response_double) { double(Net::HTTPOK, body: 'countryMatch=Yes;highRiskCountry=No;binMatch=NotFound;binNameMatch=NA', is_a?: true, code: 200) }
  let(:latin1_response_double) { double(Net::HTTPOK, body: 'ip_city=Montr\xE9al'.force_encoding("ASCII-8BIT"), is_a?: true, code: 200) }
  let(:multiple_equals_response_double) { double(Net::HTTPOK, body: 'maxmindID=ANK4C13A;ip_asnum=S44700 == Upstreams =======================================', is_a?: true, code: 200) }
  let(:warning_response_double) { double(Net::HTTPOK, body: 'err=COUNTRY_NOT_FOUND', is_a?: true, code: 200) }
  let(:error_response_double) { double(Net::HTTPOK, body: 'err=INVALID_LICENSE_KEY', is_a?: true, code: 200) }
  let(:server_error_response_double) { double(Net::HTTPRequestTimeOut, code: 408) }
  let(:err) { Faker::HipsterIpsum.word }

  describe '.new' do
    subject(:response) { Minfraud::Response.new(ok_response_double).tap {|r| r.parse} }
    subject(:test_response) { Minfraud::Response.new(test_response_double).tap {|r| r.parse} }
    subject(:boolean_test_response) { Minfraud::Response.new(boolean_test_response_double).tap {|r| r.parse} }
    subject(:latin1_response) { Minfraud::Response.new(latin1_response_double).tap {|r| r.parse} }
    subject(:multiple_equals_response) { Minfraud::Response.new(multiple_equals_response_double).tap {|r| r.parse} }
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

    it 'parse converts minfraud ISO-8859-1 output to UTF-8 automatically' do
      expect(latin1_response.ip_city.encoding).to eq(Encoding.find("UTF-8"))
      expect(latin1_response.ip_city).to eq('Montr\xE9al'.encode("UTF-8"))
    end

    it 'successfully parses input that has multiple equals operators between two semicolons' do
      expect(multiple_equals_response.maxmind_id).to eq('ANK4C13A')
      expect(multiple_equals_response.ip_asnum).to eq('S44700 == Upstreams =======================================')
    end
  end

end
