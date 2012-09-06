require 'abn-amro/internetkassa/response'
require "digest/sha1"
require "cgi"

# Possible parameters:
# https://internetkassa.abnamro.nl/ncol/param_cookbook.asp?CSRFSP=%2Fncol%2Ftest%2Fdownload_docs%2Easp&CSRFKEY=E7CC769369B47278DDF388C4FE982D235D2474E7&CSRFTS=20120906110741
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
    
    VALID_KEYS       = [ 'aavaddress', 'aavcheck', 'aavzip', 'acceptance', 'accepturl', 'addmatch', 'addrmatch', 'alias', 'aliasoperation', 'aliasusage', 'amount', 'authorization code', 'authorization date', 'authorization mode', 'url', 'bgcolor', 'bin', 'brand', 'buttonbgcolor', 'buttontxtcolor', 'cancelurl', 'cardno', 'catalogurl', 'cavv_3d', 'cavvalgorithm_3d', 'cccty', 'civility', 'cn', 'com', 'complus', 'cuid', 'currency', 'cvc', 'cvccheck', 'datatype', 'declineurl', 'device', 'digestcardno', 'eci_3d', 'ecom_billto_postal_city', 'ecom_billto_postal_countrycode', 'ecom_billto_postal_name_first', 'ecom_billto_postal_name_last', 'ecom_billto_postal_postalcode', 'ecom_billto_postal_street_line1', 'ecom_billto_postal_street_line2', 'ecom_billto_postal_street_number', 'ecom_consumer_gender', 'ecom_consumerid', 'ecom_payment_card_verification', 'ecom_shipto_dob', 'ecom_shipto_online_email', 'ecom_shipto_postal_city', 'ecom_shipto_postal_countrycode', 'ecom_shipto_postal_name_first', 'ecom_shipto_postal_name_last', 'ecom_shipto_postal_name_prefix', 'ecom_shipto_postal_postalcode', 'ecom_shipto_postal_street_line1', 'ecom_shipto_postal_street_line2', 'ecom_shipto_postal_street_number', 'ecom_shipto_telecom_fax_number', 'ecom_shipto_telecom_phone_number', 'ed', 'email', 'exceptionurl', 'exclpmlist', 'flag3d', 'fonttype', 'globorderid', 'homeurl', 'http_accept', 'http_user_agent', 'ipcty', 'itemattributes*xx*', 'itemcategory*xx*', 'itemcomments*xx*', 'itemdesc*xx*', 'itemdiscount*xx*', 'itemid*xx*', 'itemname*xx*', 'itemprice*xx*', 'itemquant*xx*', 'itemquantorig*xx*', 'itemunitofmeasure*xx*', 'itemvat*xx*', 'itemvatcode*xx*', 'itemweight*xx*', 'language', 'logo', 'ncerror', 'ncerrorplus', 'ncstatus', 'operation', 'orderid', 'owneraddress', 'ownercty', 'ownertelno', 'ownertown', 'ownerzip', 'paramplus', 'paramvar', 'payid', 'payidsub', 'pm', 'pmlist', 'pmlisttype', 'pspid', 'pswd', 'remote_addr', 'rtimeout', 'shasign', 'status', 'status_3d', 'tblbgcolor', 'tbltxtcolor', 'title', 'tp', 'trxdate', 'txtcolor', 'userid', 'vc', 'win3ds' ]
    SIGNATURE_KEYS   = [ 'acceptance', 'accepturl', 'addmatch', 'addrmatch', 'aiactionnumber', 'aiagiata', 'aiairname', 'aiairtax', 'aibookind*xx*', 'aicarrier*xx*', 'aichdet', 'aiclass*xx*', 'aiconjti', 'aideptcode', 'aidestcity*xx*', 'aidestcityl*xx*', 'aiextrapasname*xx*', 'aieycd', 'aifldate*xx*', 'aiflnum*xx*', 'aiglnum', 'aiinvoice', 'aiirst', 'aiorcity*xx*', 'aiorcityl*xx*', 'aipasname', 'aiprojnum', 'aistopov*xx*', 'aitidate', 'aitinum', 'aitinuml*xx*', 'aitypch', 'aivatamnt', 'aivatappl', 'alias', 'aliasoperation', 'aliasusage', 'allowcorrection', 'amount', 'amount*xx*', 'amounthtva', 'amounttva', 'backurl', 'batchid', 'bgcolor', 'blvernum', 'brand', 'brandvisual', 'buttonbgcolor', 'buttontxtcolor', 'cancelurl', 'cardno', 'catalogurl', 'cavv_3d', 'cavvalgorithm_3d', 'certid', 'check_aav', 'civility', 'cn', 'com', 'complus', 'costcenter', 'costcode', 'creditcode', 'cuid', 'currency', 'cvc', 'cvcflag', 'data', 'datatype', 'datein', 'dateout', 'declineurl', 'device', 'discountrate', 'displaymode', 'eci', 'eci_3d', 'ecom_billto_postal_city', 'ecom_billto_postal_countrycode', 'ecom_billto_postal_name_first', 'ecom_billto_postal_name_last', 'ecom_billto_postal_postalcode', 'ecom_billto_postal_street_line1', 'ecom_billto_postal_street_line2', 'ecom_billto_postal_street_number', 'ecom_consumerid', 'ecom_consumer_gender', 'ecom_consumerogid', 'ecom_consumerorderid', 'ecom_consumeruseralias', 'ecom_consumeruserpwd', 'ecom_consumeruserid', 'ecom_payment_card_expdate_month', 'ecom_payment_card_expdate_year', 'ecom_payment_card_name', 'ecom_payment_card_verification', 'ecom_shipto_company', 'ecom_shipto_dob', 'ecom_shipto_online_email', 'ecom_shipto_postal_city', 'ecom_shipto_postal_countrycode', 'ecom_shipto_postal_name_first', 'ecom_shipto_postal_name_last', 'ecom_shipto_postal_name_prefix', 'ecom_shipto_postal_postalcode', 'ecom_shipto_postal_street_line1', 'ecom_shipto_postal_street_line2', 'ecom_shipto_postal_street_number', 'ecom_shipto_telecom_fax_number', 'ecom_shipto_telecom_phone_number', 'ecom_shipto_tva', 'ed', 'email', 'exceptionurl', 'exclpmlist', 'executiondate*xx*', 'facexcl*xx*', 'factotal*xx*', 'firstcall', 'flag3d', 'fonttype', 'forcecode1', 'forcecode2', 'forcecodehash', 'forceprocess', 'forcetp', 'generic_bl', 'giropay_account_number', 'giropay_blz', 'giropay_owner_name', 'globorderid', 'guid', 'hdfonttype', 'hdtblbgcolor', 'hdtbltxtcolor', 'heightframe', 'homeurl', 'http_accept', 'http_user_agent', 'include_bin', 'include_countries', 'invdate', 'invdiscount', 'invlevel', 'invorderid', 'issuerid', 'ist_mobile', 'item_count', 'itemattributes*xx*', 'itemcategory*xx*', 'itemcomments*xx*', 'itemdesc*xx*', 'itemdiscount*xx*', 'itemid*xx*', 'itemname*xx*', 'itemprice*xx*', 'itemquant*xx*', 'itemquantorig*xx*', 'itemunitofmeasure*xx*', 'itemvat*xx*', 'itemvatcode*xx*', 'itemweight*xx*', 'language', 'level1authcpc', 'lidexcl*xx*', 'limitclientscriptusage', 'line_ref', 'line_ref1', 'line_ref2', 'line_ref3', 'line_ref4', 'line_ref5', 'line_ref6', 'list_bin', 'list_countries', 'logo', 'maxitemquant*xx*', 'merchantid', 'mode', 'mtime', 'mver', 'netamount', 'operation', 'orderid', 'ordershipcost', 'ordershipmeth', 'ordershiptax', 'ordershiptaxcode', 'orig', 'or_invorderid', 'or_orderid', 'owneraddress', 'owneraddress2', 'ownercty', 'ownertelno', 'ownertelno2', 'ownertown', 'ownerzip', 'paidamount', 'paramplus', 'paramvar', 'payid', 'paymethod', 'pm', 'pmlist', 'pmlistpmlisttype', 'pmlisttype', 'pmlisttypepmlist', 'pmtype', 'popup', 'post', 'pspid', 'pswd', 'ref', 'refer', 'refid', 'refkind', 'ref_customerid', 'ref_customerref', 'registred', 'remote_addr', 'reqgenfields', 'rtimeout', 'rtimeoutrequestedtimeout', 'scoringclient', 'sett_batch', 'sid', 'status_3d', 'subscription_id', 'sub_am', 'sub_amount', 'sub_com', 'sub_comment', 'sub_cur', 'sub_enddate', 'sub_orderid', 'sub_period_moment', 'sub_period_moment_m', 'sub_period_moment_ww', 'sub_period_number', 'sub_period_number_d', 'sub_period_number_m', 'sub_period_number_ww', 'sub_period_unit', 'sub_startdate', 'sub_status', 'taal', 'taxincluded*xx*', 'tblbgcolor', 'tbltxtcolor', 'tid', 'title', 'totalamount', 'tp', 'track2', 'txtbaddr2', 'txtcolor', 'txtoken', 'txtokentxtokenpaypal', 'type_country', 'ucaf_authentication_data', 'ucaf_payment_card_cvc2', 'ucaf_payment_card_expdate_month', 'ucaf_payment_card_expdate_year', 'ucaf_payment_card_number', 'userid', 'usertype', 'version', 'wbtu_msisdn', 'wbtu_orderid', 'weightunit', 'win3ds', 'withroot' ]  
    KEY_MAPPINGS     = { 'merchant_id' => 'pspid', 'description' => 'com', 'template' => 'tp', 'customer_name' => 'cn', 'payment_method' => 'pm', 'url_variable' => 'paramvar', 'endpoint_params' => 'paramplus' }
    DEFAULT_VALUES   = { 'currency' => 'EUR', 'language' => 'nl_NL' }

    MANDATORY_VALUES = [ :pspid, :orderid, :amount, :currency, :language ]
        
    PRODUCTION_URL   = "https://internetkassa.abnamro.nl/ncol/prod/orderstandard.asp"
    TEST_URL         = "https://internetkassa.abnamro.nl/ncol/test/orderstandard.asp"
    
    attr_reader :params

    def initialize(params = {})
      @params = {}
      params.each{ |key, value| @params[KEY_MAPPINGS[key.to_s] || key.to_s] = value } # stringify keys
      @params = DEFAULT_VALUES.merge('pspid' => merchant_id).merge(@params)      
      
      self.endpoint_url = @params.delete('endpoint_url') unless @params['endpoint_url'].nil?
      verify_keys!
    end
    
    def [](value)
      params[KEY_MAPPINGS[value.to_s] || value.to_s]
    end
    
    def []=(key, value)
      params[KEY_MAPPINGS[key.to_s] || key.to_s] = value
    end    
    
    # Shortcut which sets the accepturl, declineurl, cancelurl,
    # exceptionurl, and cancelurl to the specified +url+.
    def endpoint_url=(url)
      params['accepturl'] = params['declineurl'] = params['exceptionurl'] = params['cancelurl'] = url
    end
    
    def unsigned_data
      unsigned_data = {}
      params.each do |key, value| 
        unless value.nil? || value.to_s.empty?
          data_value = value.is_a?(Array) || value.is_a?(Hash) ? value.map { |k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&') : value
          unsigned_data[key.upcase] = data_value 
        end
      end
      
      unsigned_data      
    end
    
    def data
      verify_values!
      unsigned_data.merge('SHASIGN' => signature)
    end
    
    private
    
    def merchant_id
      self.class.merchant_id
    end
    
    def passphrase
      self.class.passphrase
    end
    
    def verify_keys!
      invalid_keys = params.keys - VALID_KEYS
      raise ArgumentError, "Invalid keys detected: #{invalid_keys}" if invalid_keys.any?
    end
    
    def verify_values!
      MANDATORY_VALUES.each do |key|
        raise ArgumentError, "'#{key}' can't be blank" if self[key].nil? || self[key].to_s.empty?
      end
    end
    
    def signature
      # - Create a set of all attributes needed for the signature.
      # - Remove all empty values from the set
      # - Sort the set and append PSPID to the set
      to_sign = {}
      sign_data = unsigned_data
      SIGNATURE_KEYS.map(&:upcase).each { |key| to_sign[key] = sign_data[key] if sign_data.has_key?(key) }
      Digest::SHA1.hexdigest(to_sign.sort.map{|row|row.join('=')}.push("").join(passphrase)).upcase
    end

  end
end