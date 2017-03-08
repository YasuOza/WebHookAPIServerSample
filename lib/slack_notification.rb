require 'slack-notifier'

class SlackNotification
  def notify(repository:, commits:, ref: 'refs/heads/master', after:, webhook_url:, channel:)
    ref_name, ref_path =
      if ref.match('refs/heads/')
        branch = ref.split('refs/heads/', 2).last
        ["at #{branch}", "tree/#{branch}"]
      elsif ref.match('refs/tags/')
        tag = ref.split('refs/tags/', 2).last
        ["tag #{tag}", "history/#{tag}"]
      end

    text = build_message(repository, ref_path, ref_name, after)
    attachments = build_attachments(commits, after)

    notifier = Slack::Notifier.new(webhook_url, channel: channel)
    notifier.post text: text, attachments: attachments
  end

  private

  def build_message(repository, ref_path, ref_name, after)
    operation_text =
      if delete_operation?(after)
        'is deleted'
      else
        'is just updated'
      end

    "<a href='#{repository['url']}'>#{repository['name']}</a> (<a href='#{repository['url']}/#{ref_path}'>#{ref_name}</a>) #{operation_text}"
  end

  def build_attachments(commits, after)
    [{
      text: commits_message(commits, after),
    }]
  end

  def commits_message(commits, after, limit: 4)
    return '' if commits.nil? || delete_operation?(after)

    message = commits.reverse.take(limit).reduce('') do |str, commit|
      str + "\n- #{commit['message'].split("\n").first} (<a href='#{commit['url']}'>#{commit['id'][0..7]}</a>)"
    end
    commits.length > limit ? message += "\n- and #{commits.length - limit} more" : message
  end

  def delete_operation?(after)
    after == '0000000000000000000000000000000000000000'
  end
end
