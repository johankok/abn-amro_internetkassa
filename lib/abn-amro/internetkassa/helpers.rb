module AbnAmro
  class Internetkassa
    module Helpers
      def internetkassa_form_tag(internetkassa_instance, &block)
        content_tag :form, :action => AbnAmro::Internetkassa.service_url, :method => 'post' do
          result = internetkassa_instance.data.map { |name, value| hidden_field_tag(name, value, :id => nil) }
          result << (block_given? ? capture(&block) : submit_tag('iDeal'))
          result.join("\n").html_safe
        end
      end

      def internetkassa_link_to internetkassa_instance, text = 'iDeal'
        uri = Addressable::URI.parse AbnAmro::Internetkassa.service_url
        uri.query_values = internetkassa_instance.data
        link_to text, uri.to_s
      end
    end
  end
end