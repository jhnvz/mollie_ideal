require 'webmock/rspec'
require 'mollie_ideal'
require 'support'

alias :running :lambda

RSpec.configure do |config|
  config.include SpecHelpers
end