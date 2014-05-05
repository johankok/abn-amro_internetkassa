require 'abn-amro/internetkassa/response_codes'

module AbnAmro
  class Internetkassa
    class Response
      class SignatureInvalidError < StandardError; end
      
      SHAOUT_KEYS = [ 'AAVADDRESS', 'AAVCheck', 'AAVZIP', 'ACCEPTANCE', 'ALIAS', 'amount', 'BRAND', 'CARDNO', 'CCCTY', 'CN', 'COMPLUS', 'currency', 'CVCCheck', 'DCC_COMMPERCENTAGE', 'DCC_CONVAMOUNT', 'DCC_CONVCCY', 'DCC_EXCHRATE', 'DCC_EXCHRATESOURCE', 'DCC_EXCHRATETS', 'DCC_INDICATOR', 'DCC_MARGINPERCENTAGE', 'DCC_VALIDHOUS', 'DIGESTCARDNO', 'ECI', 'ED', 'ENCCARDNO', 'IP', 'IPCTY', 'NBREMAILUSAGE', 'NBRIPUSAGE', 'NBRIPUSAGE_ALLTX', 'NBRUSAGE', 'NCERROR', 'orderID', 'PAYID', 'PM', 'SCO_CATEGORY', 'SCORING', 'STATUS', 'TRXDATE', 'VC' ]
      
      attr_reader :params
      
      def initialize(params)
        @params = params
        
        unless valid?
          raise SignatureInvalidError, "signature `#{signature}' does not match the signature calculated for this message `#{calculated_signature}'"
        end
      end
      
      # attributes
      
      def order_id;             params['orderID']                              end
      def payment_id;           params['PAYID']                                end
      def payment_method;       params['PM']                                   end
      def acceptance;           params['ACCEPTANCE']                           end
      def currency;             params['currency']                             end
      def status_code;          params['STATUS']                               end
      def error_code;           params['NCERROR'] if params['NCERROR'] != '0' && params['NCERROR'] != '' end
      def signature;            params['SHASIGN']                              end
      def customer_name;        params['CN']                                   end
      def card_brand;           params['BRAND']                                end
      def card_number;          params['CARDNO']                               end
      def card_expiration_date; params['ED']                                   end
      
      def amount
        @amount ||= (params['amount'].to_f * 100).to_i
      end
      
      def transaction_date
        @transaction_date ||= Date.strptime(params['TRXDATE'], '%m/%d/%y') if params['TRXDATE']
      end
      
      # methods
      
      def valid?
        signature == calculated_signature
      end
      
      def success?
        error_code.nil? && (authorized? || captured?)
      end
      
      def authorized?
        status_code == '5'
      end
      
      def captured?
        status_code == '9'
      end
      
      def retry?
        Codes::ERROR_CODES[error_code][:retry] if error_code
      end
      
      def status_message
        Codes::STATUS_CODES[status_code]
      end
      
      def error_message
        Codes::ERROR_CODES[error_code][:explanation] if error_code
      end
      
      private
      
      def calculated_signature
        to_sign = {}
        
        SHAOUT_KEYS.each do |param|
          to_sign.merge!(param.upcase => params[param]) unless params[param].nil? || params[param].to_s.empty?
        end

        Digest::SHA1.hexdigest(to_sign.sort.map{|row|row.join('=')}.push("").join(Internetkassa.passphrase)).upcase
      end
    end
  end
end