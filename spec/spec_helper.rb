ENV['RACK_ENV'] = 'test'
Encoding.default_external = "UTF-8" if defined? Encoding

begin
  require 'rack'
rescue LoadError
  require 'rubygems'
  require 'rack'
end

testdir = File.dirname(__FILE__)
$LOAD_PATH.unshift testdir unless $LOAD_PATH.include?(testdir)

libdir = File.dirname(File.dirname(__FILE__)) + '/lib'
$LOAD_PATH.unshift libdir unless $LOAD_PATH.include?(libdir)

# Sinatra::Application definition
def app
  Sinatra::Application
end

# Test application test configurataion
class App
  def self.root
    File.expand_path('../../', __FILE__)
  end
end

# RSpec configuration
require 'rspec'
require 'rack/test'
require 'webmock/rspec'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

# Require libraries
require 'json'
require 'yaml'
