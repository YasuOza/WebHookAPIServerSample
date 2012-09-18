# Set application user
set :user, "ApplicationUser"
set :use_sudo, false

# Set application info
set :application, "WebHookAPISereverSample"
set :repository,  "git@your_repo_url:GitLabAPIServer.git"
set :deploy_to,   "/__path__/__to__/#{application}"

# Set application environment
set :app_env, "production"
set :app_port, "4567"

set :scm, :git

role :web, "application_server.com"                   # Your HTTP server, Apache/etc
role :app, "application_server.com"                   # This may be the same as your `Web` server
role :db,  "application_server.com", :primary => true # This is where Rails migrations will run

namespace :deploy do
  desc <<-DESC
  Override for not rails application.
  DESC
  task :finalize_update do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    run "rm -rf #{latest_release}/log"
    run "ln -s #{shared_path}/log #{latest_release}/log"
  end
  task :start do
    run "cd #{current_path} && rackup config.ru -E #{app_env} -p #{app_port} -D -P #{shared_path}/pids/rack.pid"
  end
  task :stop do
    run "cat #{shared_path}/pids/rack.pid | xargs kill -s SIGINT"
  end
end
