require 'spec_helper'

describe MollieIdeal::Client do
  before(:each) do
    @client = MollieIdeal::Client.new(:partnerid => 855037, :testmode => true)
  end

  describe 'new' do
    it 'should raise a MollieException if no partnerid supplied' do
      running { MollieIdeal::Client.new({:testmode => true}) }.should raise_error(ArgumentError)
    end
  end

  describe 'banklist' do
    it 'should return a list of banks' do
      stub_request(:get, "https://secure.mollie.nl/xml/ideal?a=banklist&partnerid=855037&testmode=true").
        to_return(:status => 200, :body => fixture('banklist.xml'), :headers => {})

      banks = @client.banklist

      banks.should be_a_kind_of(Array)
      banks.first.bank_id.should eq('0031')
      banks.first.bank_name.should eq('ABN AMRO')
    end
  end

  describe 'setup_payment' do
    it 'should raise a MollieException if the amount is below 1,80EUR' do
      running { @client.setup_payment(:amount => 179) }.should raise_error(ArgumentError)
    end

    it 'should raise a MollieException if no or wrong keys supplied' do
      stub_request(:get, "https://secure.mollie.nl/xml/ideal?a=fetch&description=description&partnerid=855037&testmode=true").
        to_return(:status => 200, :body => fixture("setup_payment_error.xml"), :headers => {})

      running { @client.setup_payment(
        :description => "description"
      ) }.should raise_error(MollieIdeal::MollieException)
    end

    it 'should return URL and transaction_id' do
      stub_request(:get, "https://secure.mollie.nl/xml/ideal?a=fetch&amount=12300&bank_id=0031&description=description&partnerid=855037&reporturl=http://test.com/ideal/report&returnurl=http://test.com/ideal/return&testmode=true").
        to_return(:status => 200, :body => fixture('setup_payment.xml'), :headers => {})

      response = @client.setup_payment(
        :amount => 12300,
        :bank_id => '0031',
        :returnurl => "http://test.com/ideal/return",
        :reporturl => "http://test.com/ideal/report",
        :description => "description"
      )

      response.URL.should eq('https://mijn.postbank.nl/internetbankieren/SesamLoginServlet?sessie=ideal&trxid=003123456789123&random=123456789abcdefgh&testmode=true')
      response.transaction_id.should eq('482d599bbcc7795727650330ad65fe9b')
    end
  end

  describe 'check_payment' do
    it 'should return a transaction' do
      stub_request(:get, "https://secure.mollie.nl/xml/ideal?a=check&partnerid=855037&testmode=true&transaction_id=482d599bbcc7795727650330ad65fe9b").
        to_return(:status => 200, :body => fixture('check_payment.xml'), :headers => {})

      response = @client.check_payment('482d599bbcc7795727650330ad65fe9b')
      response.payed.should eq('true')
    end

    it 'should raise an MollieException if no transaction was found' do
      stub_request(:get, "https://secure.mollie.nl/xml/ideal?a=check&partnerid=855037&testmode=true&transaction_id=noop").
        to_return(:status => 200, :body => fixture('check_payment_error.xml'), :headers => {})

      running { @client.check_payment('noop') }.should raise_error(MollieIdeal::MollieException)
    end
  end
end