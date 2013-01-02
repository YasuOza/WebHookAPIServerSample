require 'yaml'
require 'net/http'
require 'openssl'

class TriggerJenkins
  def initialize(jobname, opt = {build_token: nil})
    @jobname = jobname

    load_config(opt[:build_token])
  end

  def trigger
    uri = URI("#{@server}/job/#{@jobname}/build?token=#{@build_token}&cause=git+push")

    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth @user, @user_token

    res = Net::HTTP.start(uri.hostname,
                          uri.port,
                          use_ssl: uri.scheme == 'https',
                          verify_mode: OpenSSL::SSL::VERIFY_NONE) { |http|
      http.request(request)
    }

    "#{res.code}: #{res.msg}"
  end

  private
    def load_config(build_token = nil)
      config = YAML.load_file(File.join(File.expand_path('../../config', __FILE__), 'jenkins.yml'))

      @server = config['server']
      @user = config['user']
      @user_token = config['user_token']
      @build_token = build_token || config['default_build_token']
    end
end

