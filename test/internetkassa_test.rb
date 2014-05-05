require File.expand_path('../test_helper', __FILE__)

describe "AbnAmro::Internetkassa, class methods" do
  it "should return whether or not it's in test mode" do
    assert AbnAmro::Internetkassa.test?
  end
  
  it "should return the PSPID with #pspid or its aliased handsome cousin #merchant_id" do
    AbnAmro::Internetkassa.pspid.should == 'fingertips'
    AbnAmro::Internetkassa.merchant_id.should == 'fingertips'
  end
  
  it "should return the passphrase used to sign the messages to the payment server" do
    AbnAmro::Internetkassa.shasign.should == 'supersecret'
    AbnAmro::Internetkassa.passphrase.should == 'supersecret'
  end
  
  it "should have the correct service_urls" do
    AbnAmro::Internetkassa::TEST_URL.should ==
      "https://internetkassa.abnamro.nl/ncol/test/orderstandard.asp"
    
    AbnAmro::Internetkassa::PRODUCTION_URL.should ==
      "https://internetkassa.abnamro.nl/ncol/prod/orderstandard.asp"
  end
  
  it "should return the service_url for the current environment" do
    begin
      AbnAmro::Internetkassa.test = true
      AbnAmro::Internetkassa.service_url.should ==
        AbnAmro::Internetkassa::TEST_URL
      
      AbnAmro::Internetkassa.test = false
      AbnAmro::Internetkassa.service_url.should ==
        AbnAmro::Internetkassa::PRODUCTION_URL
    ensure
      AbnAmro::Internetkassa.test = true
    end
  end
end

describe "AbnAmro::Internetkassa, an instance" do
  before do
    @valid_attributes = {
      :orderid => 123,
      :amount => 1000,
      :description => "HappyHardcore vol. 123 - the ballads",
      :endpoint_url => "http://example.com/payments",
      :url_variable => ":id",
      :endpoint_params => [[:session_id, 'abcde12345'], [:message, '"Thanks for your purchase"']]
    }
    @instance = AbnAmro::Internetkassa.new(@valid_attributes)
  end
  
  it "should have assigned the constructor arguments" do
    @instance['orderid'].should    == 123
    @instance['amount'].should      == 1000
    @instance['description'].should == "HappyHardcore vol. 123 - the ballads"
  end
  
  it "should have used the endpoint_url shortcut to set all endpoint urls" do
    @instance['accepturl'].should    == "http://example.com/payments"
    @instance['declineurl'].should   == "http://example.com/payments"
    @instance['exceptionurl'].should == "http://example.com/payments"
    @instance['cancelurl'].should    == "http://example.com/payments"
  end
  
  it "should have merged default values" do
    @instance['currency'].should == 'EUR'
    @instance['language'].should == 'nl_NL'
  end
  
  it "should return the url_variable" do
    @instance['url_variable'].should == ":id"
  end
  
  it "should return the extra params" do
    @instance['endpoint_params'].should == [[:session_id, 'abcde12345'], [:message, '"Thanks for your purchase"']]
  end
  
  it "should have access to the pspid/merchant_id" do
    @instance.send(:merchant_id).should == AbnAmro::Internetkassa.merchant_id
  end
  
  it "should have access to the shasign/passphrase" do
    @instance.send(:passphrase).should == AbnAmro::Internetkassa.passphrase
  end
  
  it "should verify that the mandatory values are specified or raise an ArgumentError" do
    %w{ merchant_id orderid amount currency language }.each do |key|
      instance = AbnAmro::Internetkassa.new(@valid_attributes)
      instance[key] = nil
      lambda { instance.send(:verify_values!) }.should.raise ArgumentError
    end
  end
  
  it "should create a SHA1 signature for the message" do
    @instance = AbnAmro::Internetkassa.new(:orderid => 123, :amount => 1000)
    message = "AMOUNT=#{@instance['amount']}#{AbnAmro::Internetkassa.passphrase}CURRENCY=#{@instance['currency']}#{AbnAmro::Internetkassa.passphrase}LANGUAGE=#{@instance['language']}#{AbnAmro::Internetkassa.passphrase}ORDERID=#{@instance['orderid']}#{AbnAmro::Internetkassa.passphrase}PSPID=#{AbnAmro::Internetkassa.merchant_id}#{AbnAmro::Internetkassa.passphrase}"
    @instance.send(:signature).should == Digest::SHA1.hexdigest(message).upcase
  end
  
  it "should return the key-value pairs that should be POSTed, according to the Internetkassa specs" do
    @instance.data.should == {
      'PSPID'        => AbnAmro::Internetkassa.merchant_id,
      'ORDERID'      => @instance['orderid'],
      'AMOUNT'       => @instance['amount'],
      'CURRENCY'     => @instance['currency'],
      'LANGUAGE'     => @instance['language'],
      'COM'          => @instance['description'],
      'SHASIGN'      => @instance.send(:signature),
      'PARAMVAR'     => @instance['url_variable'],
      'PARAMPLUS'    => "session_id=abcde12345&message=%22Thanks+for+your+purchase%22",
      'ACCEPTURL'    => @valid_attributes[:endpoint_url],
      'DECLINEURL'   => @valid_attributes[:endpoint_url],
      'EXCEPTIONURL' => @valid_attributes[:endpoint_url],
      'CANCELURL'    => @valid_attributes[:endpoint_url]
    }
  end
  
  it "should check if all mandatory values are specified before returning the `data'" do
    @instance.expects(:verify_values!)
    @instance.data
  end
  
  it "should merge any optional arguments with the data" do
    @valid_attributes[:title] = 'My Transaction'
    @instance = AbnAmro::Internetkassa.new(@valid_attributes)
    @instance.data.should == {
      'PSPID'        => AbnAmro::Internetkassa.merchant_id,
      'ORDERID'      => @instance['orderid'],
      'AMOUNT'       => @instance['amount'],
      'CURRENCY'     => @instance['currency'],
      'LANGUAGE'     => @instance['language'],
      'COM'          => @instance['description'],
      'SHASIGN'      => @instance.send(:signature),
      'PARAMVAR'     => @instance['url_variable'],
      'PARAMPLUS'    => "session_id=abcde12345&message=%22Thanks+for+your+purchase%22",
      'ACCEPTURL'    => @valid_attributes[:endpoint_url],
      'DECLINEURL'   => @valid_attributes[:endpoint_url],
      'EXCEPTIONURL' => @valid_attributes[:endpoint_url],
      'CANCELURL'    => @valid_attributes[:endpoint_url],
      'TITLE'        => 'My Transaction'
    }
  end
  
  it "should not return blank values in the data" do
    @instance['url_variable'] = nil
    @instance.data.should.not.has_key :PARAMVAR
    
    @instance['url_variable'] = ''
    @instance.data.should.not.has_key :PARAMVAR
  end
end