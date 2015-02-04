require 'spec_helper'
require 'hipchatter'

describe HipChatter do
  let!(:payload) { JSON.parse(File.open(File.expand_path('../params.json', __dir__)).read) }
  let!(:repository) { payload['repository'] }
  let!(:commits) { payload['commits'] }

  describe '#notify' do
    subject { HipChatter.new(repository: repository, commits: commits).notify(token: 'my-token', to: 'my-room', from: 'me') }
    it do
      message = <<-MEG
<a href='http://source.yasuoza.com/HelloSinatraServer'>HelloSinatraServer</a> is just updated
- Add not_found method and spec test (<a href='http://source.yasuoza.com/HelloSinatraServer/commits/a6d4772bbc540a12f7501274f60abd406e95ae24'>a6d4772bbc540a12f7501274f60abd406e95ae24</a>)
- Add /api/:service (<a href='http://source.yasuoza.com/HelloSinatraServer/commits/42c40f9dfe82fd93ddd997d1af6088866a55854e'>42c40f9dfe82fd93ddd997d1af6088866a55854e</a>)
- Add server configuration file (<a href='http://source.yasuoza.com/HelloSinatraServer/commits/de925271b9ce60a7261f0bec7e028bfef4f7205a'>de925271b9ce60a7261f0bec7e028bfef4f7205a</a>)
- Write params to params.txt when /api/twtr was called (<a href='http://source.yasuoza.com/HelloSinatraServer/commits/9e57debdf934cf8eee8eaced6aff823b38ee5e9c'>9e57debdf934cf8eee8eaced6aff823b38ee5e9c</a>)
      MEG

      client = instance_spy(HipChat::Client)
      expect(HipChat::Client).to receive(:new).with('my-token', api_version: 'v2').and_return(client)
      expect(client).to receive(:[]).with('my-room')
      expect(client).to receive(:send).with('me', message)
      subject
    end
  end
end
