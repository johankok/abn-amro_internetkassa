Gem::Specification.new do |spec|
  spec.name = 'internetkassa'
  spec.version = '1.0.0'
  
  spec.homepage = 'https://github.com/moiristo/abn-amro_internetkassa.git'
  spec.description = spec.summary = %{A library to make online payments using ABN-AMRO (Dutch bank) Internetkassa.}
  
  spec.author = 'Eloy Duran'
  spec.email = 'eloy@fngtps.com'
  
  spec.files = %w{
    Rakefile
    README.rdoc
    LICENSE
    lib/abn-amro/internetkassa.rb
    lib/abn-amro/internetkassa/response.rb
    lib/abn-amro/internetkassa/response_codes.rb
    lib/abn-amro/internetkassa/helpers.rb
    rails/init.rb
    test/fixtures.rb
    test/helpers/fixtures_helper.rb
    test/helpers_test.rb
    test/internetkassa_test.rb
    test/internetkassa_remote_test.rb
    test/response_test.rb
    test/response_regression_test.rb
    test/test_helper.rb
  }
  
  spec.has_rdoc = true
  spec.extra_rdoc_files = %w{ README.rdoc LICENSE }
  spec.rdoc_options << '--charset=utf-8' << '--main=README.rdoc'
  
  if spec.respond_to?(:add_development_dependency)
    spec.add_development_dependency 'rails'
    spec.add_development_dependency 'rake' 
    spec.add_development_dependency 'test-unit'
    spec.add_development_dependency 'test-spec'           
    spec.add_development_dependency 'mocha', '>= 0.12.4'
    spec.add_development_dependency 'rest-client'
    spec.add_development_dependency 'hpricot'       
    spec.add_development_dependency 'debugger'      
  end
end