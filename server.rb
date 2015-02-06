require 'sinatra'
require 'twitter'
require 'json'

# Configuration file
require File.expand_path('config/setting', __dir__)

# require libraries
Dir[File.join(File.expand_path('../', __FILE__), 'lib/**/*.rb')].each do |file|
  require file
end

# /:service/hipchat/:room?token=hipchat_api_token
# Supprt gitlab, github, backlog service
#
# Receive web post_receive hook and send hipchat message
post '/:service/hipchat/:room' do |service, room|
  repository, commits =
    case service
    when /gitlab/i
      data = JSON.parse(request.body.read)
      [data['repository'], data['commits']]
    when /github/i
      data = JSON.parse(request.body.read)['payload']
      [data['repository'], data['commits']]
    when /backlog/i
      data = JSON.parse(request.body.read)['payload']
      [data['repository'], data['revisions']]
    end
  HipChatter.new(repository: repository, commits: commits)
            .notify(token: params[:token], to: room, from: service)
  "OK"
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
  Tweeter.tweet_with(settings.twtrclient, data, settings.mention_to)
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
