require 'hipchat'

class HipChatter
  def initialize(repository:, commits:)
    @repository = repository
    @commits = commits
  end

  def notify(token:, to:, from: 'HipChatter')
    client = HipChat::Client.new(token, api_version: 'v2')
    client[to].send(from, build_message)
  end

  private

  def build_message
    message = "<a href='#{@repository['url']}'>#{@repository['name']}</a> is just updated\n"
    message += commits_message
  end

  def commits_message
    @commits.reduce('') do |str, commit|
      str + "- #{commit['message']} (<a href='#{commit['url']}'>#{commit['id']}</a>)\n"
    end
  end
end
