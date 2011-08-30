require "#{File.expand_path('./lib')}/recipies/common"

Capistrano::Configuration.instance.load do
  
  set :unicorn_config, "#{current_path}/config/unicorn.rb"
  set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"
  set :unicorn_socket, "#{current_path}/tmp/sockets/unicorn.sock"
    
  # configure the app server (unicorn)
  task :configure_unicorn do
    generate_from_template("/etc/templates/unicorn.rb.tmpl", unicorn_config)
  #  sudo "mv #{unicorn_remote_config} #{where_to_move_the_unicorn config}"
  end
  
  namespace :unicorn do
    task :start, :roles => :app, :except => { :no_release => true } do
      run "cd #{current_path} && rvmsudo unicorn -c #{unicorn_config} -E #{rails_env} -D"
    end

    task :stop, :roles => :app, :except => { :no_release => true } do 
      run "if [ -e '#{unicorn_pid}' ]; then #{try_sudo} kill `cat #{unicorn_pid}`; sleep 5; fi;"
    end

    task :graceful_stop, :roles => :app, :except => { :no_release => true } do
      run "if [ -e '#{unicorn_pid}' ]; then #{try_sudo} kill -s QUIT `cat #{unicorn_pid}`; sleep 5; fi"
    end

    task :reload, :roles => :app, :except => { :no_release => true } do
      run "#if [ -e '#{unicorn_pid}' ]; then #{try_sudo} kill -s USR2 `cat #{unicorn_pid}`; fi"
    end
  end
  
  before 'deploy:restart', "configure_unicorn"
  before 'deploy:start', "configure_unicorn"
  
  after 'deploy:start', 'unicorn:start'
  after 'deploy:stop', 'unicorn:stop'
  after 'deploy:reload', 'unicorn:reload'
  after 'deploy:graceful_stop', 'unicorn:graceful_stop'
end