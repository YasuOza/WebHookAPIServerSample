require 'pry'

class Tweeter
  # tweet_with +json_parsed_hash+ and return json serialized update result message
  #
  # tweet_with(hash_data)
  # # => {"message": "Upate status 4 times"}
  def self.tweet_with(client, data, mention_to)
    update_count = 0
    data['commits'].each do |commit|
      update_status_with(client, "@#{mention_to} #{data['repository']['name']} - #{commit['message']}")
      update_count += 1
    end
    JSON.generate(message: "Update status #{update_count} " + (update_count > 1 ? "times" : "time"))
  end

  private
    # update_status +string+ calls twitter api
    def self.update_status_with(client, text)
      return unless Sinatra::Application.settings.production?
      client.update(text)
    end
end
