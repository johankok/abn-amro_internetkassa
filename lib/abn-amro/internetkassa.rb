require 'abn-amro/internetkassa/response'
require "digest/sha1"
require "cgi"

module AbnAmro
  class Internetkassa
    class << self
      attr_accessor :pspid, :shasign, :test
      
      alias_method :merchant_id=, :pspid=
      alias_method :merchant_id,  :pspid
      
      alias_method :passphrase=,  :shasign=
      alias_method :passphrase,   :shasign
      
      def test?
        @test
      end
      
      def service_url
        test? ? TEST_URL : PRODUCTION_URL
      end
    end
    
    MANDATORY_VALUES = %w{ merchant_id order_id amount currency language }
    DEFAULT_VALUES   = { :currency => 'EUR', :language => 'nl_NL' }
    PRODUCTION_URL   = "https://internetkassa.abnamro.nl/ncol/prod/orderstandard.asp"
    TEST_URL         = "https://internetkassa.abnamro.nl/ncol/test/orderstandard.asp"
    
    attr_reader :params
    
    attr_accessor :order_id, :amount, :description, :currency, :language
    attr_accessor :brand, :payment_method
    attr_accessor :accept_url, :decline_url, :exception_url, :cancel_url
    attr_accessor :url_variable, :endpoint_params
    attr_accessor :template
    attr_accessor :customer_name, :customer_email, :customer_address
    attr_accessor :customer_zipcode, :customer_town, :customer_country
    attr_accessor :customer_telno
    
    def initialize(params = {})
      @params = {}
      
      DEFAULT_VALUES.merge(params).each do |k,v|
        if respond_to?("#{k}=")
          send("#{k}=", v)
        else
          @params[k] = v
        end
      end
    end
    
    # Shortcut which sets the accept_url, decline_url, cancel_url,
    # exception_url, and cancel_url to the specified +url+.
    def endpoint_url=(url)
      @accept_url = @decline_url = @exception_url = @cancel_url = url
    end
    
    def data
      verify_values!
      @params.merge(
        :PSPID        => merchant_id,
        :orderID      => @order_id,
        :amount       => @amount,
        :currency     => @currency,
        :language     => @language,
        :COM          => @description,
        :SHASign      => signature,
        :PARAMVAR     => @url_variable,
        :PARAMPLUS    => url_encoded_endpoint_params,
        :BRAND        => @brand,
        :PM           => @payment_method,
        :accepturl    => @accept_url,
        :declineurl   => @decline_url,
        :exceptionurl => @exception_url,
        :cancelurl    => @cancel_url,
        :TP           => @template,
        :CN           => @customer_name,
        :EMAIL        => @customer_email,
        :owneraddress => @customer_address,
        :ownerZIP     => @customer_zipcode,
        :ownertown    => @customer_town,
        :ownercty     => @customer_country,
        :ownertelno   => @customer_telno
      ).delete_if { |key, value| value.nil? || value.to_s.empty? }
    end
    
    private
    
    def merchant_id
      self.class.merchant_id
    end
    
    def passphrase
      self.class.passphrase
    end
    
    def verify_values!
      MANDATORY_VALUES.each do |key|
        raise ArgumentError, "`#{key}' can't be blank" if send(key).nil?
      end
    end
    
    def signature
      # - Create a set of all attributes needed for the signature.
      # - Remove all empty values from the set
      # - Sort the set and append PSPID to the set
      to_sign = {
        'ACCEPTURL'    => @accept_url,
        'AMOUNT'       => @amount,
        'BRAND'        => @brand,
        'CANCELURL'    => @cancel_url,
        'CN'           => @customer_name,
        'COM'          => @description,
        'CURRENCY'     => @currency,
        'DECLINEURL'   => @decline_url,
        'EMAIL'        => @customer_email,
        'EXCEPTIONURL' => @exception_url,
        'LANGUAGE'     => @language,
        'ORDERID'      => @order_id,
        'OWNERADDRESS' => @customer_address,
        'OWNERCTY'     => @customer_country,
        'OWNERTELNO'   => @customer_telno,
        'OWNERTOWN'    => @customer_town,
        'OWNERZIP'     => @customer_zipcode,
        'PARAMPLUS'    => url_encoded_endpoint_params,
        'PARAMVAR'     => @url_variable,
        'PM'           => @payment_method,
        'PSPID'        => merchant_id,
        'TP'           => @template
      }.delete_if{ |k,v| v.nil? || v.to_s.empty? }.sort
      Digest::SHA1.hexdigest(to_sign.map{|row|row.join('=')}.push("").join(passphrase)).upcase
    end
    
    def url_encoded_endpoint_params
      return unless @endpoint_params
      @endpoint_params.map { |k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
    end
  end
end
