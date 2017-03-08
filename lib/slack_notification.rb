require 'slack-notifier'

class SlackNotification
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

  def notify(webhook_url:, channel:)
    notifier = Slack::Notifier.new(webhook_url, channel: channel)
    message = build_message
    notifier.ping(message)
  end

  private

  def build_message
    message = "<a href='#{@repository['url']}'>#{@repository['name']}</a> (<a href='#{@repository['url']}/#{@ref_path}'>#{@ref_name}</a>) is just updated"
    message += commits_message
  end

  def commits_message(limit: 4)
    return '' if @commits.nil?
    message = @commits.reverse.take(limit).reduce('') do |str, commit|
      str + "\n- #{commit['message'].split("\n").first} (<a href='#{commit['url']}'>#{commit['id'][0..7]}</a>)"
    end
    @commits.length > limit ? message += "\n- and #{@commits.length - limit} more" : message
  end
end
