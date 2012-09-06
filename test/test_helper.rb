require 'rubygems' rescue LoadError
require 'bundler/setup'
require 'test/spec'
require 'mocha'
require 'debugger'

require File.expand_path('../helpers/view_helper', __FILE__)

require File.expand_path('../helpers/fixtures_helper', __FILE__)
require File.expand_path('../fixtures', __FILE__)

$:.unshift File.expand_path('../../lib', __FILE__)
require 'abn-amro/internetkassa'
require 'abn-amro/internetkassa/helpers'

AbnAmro::Internetkassa.test = true
AbnAmro::Internetkassa.merchant_id = 'fingertips'
AbnAmro::Internetkassa.passphrase = 'supersecret'