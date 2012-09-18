require 'sinatra'
require 'twitter'
require 'json'

# Configuration file
require File.expand_path('../config/setting', __FILE__)

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
  tweet_with(data)
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

# Private method
# tweet_with +json_parsed_hash+ and return json serialized update result message
#
# tweet_with(hash_data)
# # => {"message": "Upate status 4 times"}
def tweet_with(data)
  update_count = 0
  data['commits'].each do |commit|
    update_status_with("@#{settings.mention_to} #{data['repository']['name']} - #{commit['message']}")
    update_count += 1
  end
  JSON.generate(message: "Update status #{update_count} " + (update_count > 1 ? "times" : "time"))
end

# Private method
# update_status +string+ calls twitter api
def update_status_with(text)
  return unless production?
  Twitter.update(text)
end
