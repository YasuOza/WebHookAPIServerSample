require File.expand_path('../../spec_helper', __FILE__)

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
