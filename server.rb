require 'sinatra'
require 'json'

# Configuration file
require File.expand_path('config/setting', __dir__)

# require libraries
Dir[File.join(File.expand_path('../', __FILE__), 'lib/**/*.rb')].each do |file|
  require file
end

# /hipchat/hipchat/:room?token=hipchat_api_token
# Receive web post_receive hook and send hipchat message
post '/backlog/hipchat/:room' do |room|
  body = URI.decode_www_form_component(request.body.read).gsub(/^payload=/, '')
  data = JSON.parse(body)

  repository = data['repository']
  commits = data['revisions']
  ref = data['ref']
  HipChatter.new(repository: repository, commits: commits, ref: ref)
            .notify(token: params[:token], to: room, from: service)
  "OK"
end

post '/backlog/slack/:channel' do |channel|
  body = URI.decode_www_form_component(request.body.read).gsub(/^payload=/, '')
  data = JSON.parse(body)

  repository = data['repository']
  commits = data['revisions']
  ref = data['ref']
  after = data['after']
  SlackNotification.new.notify(repository: repository, commits: commits, ref: ref,
                               after: after, webhook_url: settings.slack_webhook_url, channel: channel)
  "OK"
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
