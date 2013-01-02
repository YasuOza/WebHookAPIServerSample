require 'sinatra'
require 'twitter'
require 'json'

# Configuration file
require File.expand_path('../config/setting', __FILE__)

# require libraries
Dir[File.join(File.expand_path('../', __FILE__), 'lib/**/*.rb')].each do |file|
  require file
end

# /:service/twtr
# Supprt /gitlab/twtr and /github/twtr
#
# Receive web post_receive hook and update twitter status
post '/:service/twtr' do |service|
  # Filter via ip address
  return 403 unless settings.allowed_ips.include?(request.ip)

  case service
  when 'gitlab'
    data = JSON.parse(request.body.read)
  when 'github'
    data = JSON.parse(params[:payload])
  end
  Tweeter.tweet_with(data)
end

# /:service/twtr
# Supprt /gitlab/twtr and /github/twtr
#
# Receive web post_receive hook and update twitter status
post '/jenkins/trigger' do
  # Filter via ip address
  return 403 unless settings.allowed_ips.include?(request.ip)

  TriggerJenkins.new(params[:jobname], build_token: params[:build_token]).trigger
end

# Global api
#
# 404 Not found
not_found do
  'This is nowhere to be found'
end

# Global api
#
# 403 Access forbidden
error 403 do
  'Access forbidden'
end
