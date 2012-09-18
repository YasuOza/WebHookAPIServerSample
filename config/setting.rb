# Configure sinatra server
# For available variables, see
# http://www.sinatrarb.com/configuration.html

set :port, 4567
set :mention_to, 'YourTwitterID'
set :allowed_ips, ['127.0.0.2', '207.97.227.253', '50.57.128.197', '108.171.174.178']

# Twitter configuration
Twitter.configure do |config|
  config.consumer_key = 'consumer_key'
  config.consumer_secret = 'consumer_secret'
  config.oauth_token = 'your_oauth_token'
  config.oauth_token_secret = 'oauth_token_secret'
end
