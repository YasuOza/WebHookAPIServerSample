# http://stackoverflow.com/a/25398831
$stdout.sync = true

require File.expand_path('../server', __FILE__)

run Sinatra::Application
