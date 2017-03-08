# Configure sinatra server
# For available variables, see
# http://www.sinatrarb.com/configuration.html

set :port, ENV['PORT']             || 4567

set :slack_webhook_url, ENV['SLACK_WEBHOOK_URL']
