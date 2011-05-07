$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'eeepub'
require 'rspec'
require 'nokogiri'
require 'rr'
require 'simplecov'

RSpec.configure do |config|
  config.mock_with :rr
end

SimpleCov.start

