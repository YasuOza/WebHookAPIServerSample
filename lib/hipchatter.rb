require 'hipchat'

class HipChatter
  def initialize(repository: repository, commits: commits)
    @repository = repository
    @commits = commits
  end

  def notify(to: 'room', from: 'HipChatter')
    api_token = 'hello-api'
    client = HipChat::Client.new(api_token, api_version: 'v2')
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
