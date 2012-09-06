require File.expand_path('../test_helper', __FILE__)

describe "AbnAmro::Internetkassa::Helpers", ActionView::TestCase do
  
  before do
    @instance = AbnAmro::Internetkassa.new(
      :orderid => 123,
      :amount => 1000,
      :description => "HappyHardcore vol. 123 - the ballads",
      :endpoint_url => "http://example.com/payments",
      :title => 'HappyHardcore vol. 123 - the ballads'
    )
    
    # make sure we don't get bitten by sorting
    ordered_data = @instance.data.to_a
    @instance.stubs(:data).returns(ordered_data)
  end
  
  it "should create a form tag with the AbnAmro::Internetkassa.service_url as its action" do
    expected = %{<form action="#{AbnAmro::Internetkassa.service_url}" method="post">}
    internetkassa_form_tag(@instance)[0..expected.length-1].should == expected
  end
  
  it "should create a form with data from a AbnAmro::Internetkassa instance and yield" do
    form_tag = internetkassa_form_tag(@instance) { submit_tag('Betaal') }

    form_start = %{<form action="#{AbnAmro::Internetkassa.service_url}" method="post">} 
    form_end   = '</form>'
    
    inputs = @instance.data.map do |name, value|
      %{<input name="#{name}" type="hidden" value="#{value}" />}
    end
    
    inputs << %{<input name="commit" type="submit" value="Betaal" />}    
    
    assert_dom_equal "#{form_start}#{inputs.join("\n")}#{form_end}", form_tag
  end
end