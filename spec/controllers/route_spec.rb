require File.expand_path('../../spec_helper', __FILE__)
require 'rspec/its'

# Target file
require "#{App.root}/server"

describe 'Post receive api Server' do
  describe :not_found do
    subject { last_response }

    before(:all) do
      get '/hello_world'
    end

    its(:status) { should be 404}
    its(:body) { should eql "This is nowhere to be found" }
  end

  describe 'POST /gitlab' do
    subject { last_response }

    describe '/foobar' do
      before do
        post '/gitlab/foobar', {key: 'value', key2: 'value2'}
      end

      its(:body) { should eq "This is nowhere to be found" }
    end

    describe '/twtr' do
      context 'invalid IP ' do
        before do
          post '/gitlab/twtr', File.read(File.expand_path('../../params.json', __FILE__)),
               'REMOTE_ADDR' => '255.255.255.255'
        end

        its(:status) { should eq 403 }
        its(:body) { should eq "Access forbidden" }
      end

      context 'valid IP' do
        before do
          post '/gitlab/twtr', File.read(File.expand_path('../../params.json', __FILE__)),
               'REMOTE_ADDR' => '127.0.0.2'
        end

        its(:body) { should eq JSON.generate(message: 'Update status 4 times') }
      end
    end
  end

  describe 'POST /github' do
    subject { last_response }

    describe '/foobar' do
      before do
        post '/github/foobar', {key: 'value', key2: 'value2'}
      end

      its(:body) { should eq "This is nowhere to be found" }
    end

    describe '/hipchat' do
      subject do
        post '/github/hipchat/my-room?token=my-token',
          { payload: File.read(File.expand_path('../params.json', __dir__)) }
      end

      it 'sends message' do
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
        expect(client).to receive(:send).with('github', message)
        subject
      end
    end

    describe '/twtr' do
      context 'invalid IP ' do
        before do
          post '/github/twtr', File.read(File.expand_path('../../params.json', __FILE__)),
               'REMOTE_ADDR' => '255.255.255.255'
        end

        its(:status) { should eq 403 }
        its(:body) { should eq "Access forbidden" }
      end

      context 'valid IP' do
        before do
          post '/github/twtr',
               {payload: File.read(File.expand_path('../../params.json', __FILE__))},
               'REMOTE_ADDR' => ['207.97.227.253', '50.57.128.197', '108.171.174.178'][rand(3)]
        end

        its(:body) { should eq JSON.generate(message: 'Update status 4 times') }
      end
    end

    describe '/jenkins/trigger' do
      context 'invalid IP ' do
        before do
          post '/jenkins/trigger', 'REMOTE_ADDR' => '255.255.255.255'
        end

        its(:status) { should eq 403 }
        its(:body) { should eq "Access forbidden" }
      end

      context 'valid IP' do
        before do
          config_file_path = File.join(App.root, 'config/jenkins.yml')
          config = YAML.load_file(config_file_path)
          scheme, host_name = config['server'].match(%r((https?)://([\w\.]+))).captures

          endpoint = "#{scheme}://#{config['user']}:#{config['user_token']}@#{host_name}"
          endpoint << "/job/HelloJenkinsJob"
          endpoint << "/build?cause=git%20push&token=#{config['default_build_token']}"

          stub_request(:get, endpoint).to_return(:status => [302, "Found"])

          post '/jenkins/trigger?jobname=HelloJenkinsJob',
               nil,
               'REMOTE_ADDR' => '127.0.0.2'
        end

        its(:body) { should eq '302: Found' }
      end
    end
  end
end
