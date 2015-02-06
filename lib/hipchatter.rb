require 'hipchat'

class HipChatter
  def initialize(repository:, commits:)
    @repository = repository
    @commits = commits
  end

  def notify(token:, to:, from: 'HipChatter')
    client = HipChat::Client.new(token)
    client[to].send(from, build_message)
  end

  private

  def build_message
    message = "<a href='#{@repository['url']}'>#{@repository['name']}</a> is just updated"
    message += commits_message
  end

  def commits_message
    limit = 4
    message = @commits[0...limit].reduce('') do |str, commit|
      str + "<br/>- #{commit['message']} (<a href='#{commit['url']}'>#{commit['id'][0..7]}</a>)"
    end
    @commits.length > limit ? message += "<br/>- and #{@commits.length - limit} more" : message
  end
end
