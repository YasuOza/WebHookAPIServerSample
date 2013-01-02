class Tweeter
  # tweet_with +json_parsed_hash+ and return json serialized update result message
  #
  # tweet_with(hash_data)
  # # => {"message": "Upate status 4 times"}
  def self.tweet_with(data)
    update_count = 0
    data['commits'].each do |commit|
      update_status_with("@#{settings.mention_to} #{data['repository']['name']} - #{commit['message']}")
      update_count += 1
    end
    JSON.generate(message: "Update status #{update_count} " + (update_count > 1 ? "times" : "time"))
  end

  private
    # update_status +string+ calls twitter api
    def self.update_status_with(text)
      return unless production?
      Twitter.update(text)
    end
end
