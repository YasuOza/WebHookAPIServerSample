require 'hipchat'

class HipChatter
  def initialize(repository:, commits:, ref: 'refs/heads/master')
    @repository = repository
    @commits = commits

    @ref_name, @ref_path =
      if ref.match('refs/heads/')
        branch = ref.split('refs/heads/', 2).last
        ["at #{branch}", "tree/#{branch}"]
      elsif ref.match('refs/tags/')
        tag = ref.split('refs/tags/', 2).last
        ["tag #{tag}", "history/#{tag}"]
      end
  end

  def notify(token:, to:, from: 'HipChatter')
    client = HipChat::Client.new(token)
    client[to].send(from, build_message, notify: true)
  end

  private

  def build_message
    message = "<a href='#{@repository['url']}'>#{@repository['name']}</a> (<a href='#{@repository['url']}/#{@ref_path}'>#{@ref_name}</a>) is just updated"
    message += commits_message
  end

  def commits_message
    return '' if @commits.nil?
    limit = 4
    message = @commits[0...limit].reduce('') do |str, commit|
      str + "<br/>- #{commit['message'].split("\n").first} (<a href='#{commit['url']}'>#{commit['id'][0..7]}</a>)"
    end
    @commits.length > limit ? message += "<br/>- and #{@commits.length - limit} more" : message
  end
end
