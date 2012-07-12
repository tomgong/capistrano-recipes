set :shared_children, shared_children << 'tmp/sockets'

set_default(:puma_log) { "#{current_path}/log/puma-#{stage}.log" }
set_default(:puma_socket) { "#{current_path}/tmp/sockets/unicorn.sock"}
set_default(:puma_state_socket) { "#{current_path}/tmp/sockets/pumactl.sock"}

namespace :deploy do
  desc "Start the application"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{stage} bundle exec puma -b 'unix://#{puma_socket}' -S #{puma_state_socket} --control auto >> #{puma_log} 2>&1 &", :pty => false
  end

  desc "Stop the application"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{stage} bundle exec pumactl -S #{puma_state_socket} stop"
  end

  desc "Restart the application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{stage} bundle exec pumactl -S #{puma_state_socket} restart"
  end

  desc "Status of the application"
  task :status, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{stage} bundle exec pumactl -S #{puma_state_socket} stats"
  end
end
