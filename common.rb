def generate_from_template(template_to_get, remote_file_to_put)
  require 'erb'  #render not available in Capistrano 2

  template=File.read("#{File.expand_path('./lib')}/recipies/templates/#{template_to_get}") # read it
  buffer= ERB.new(template).result(binding)            # parse it
  put buffer, remote_file_to_put                       # put the result
end

# common definitions
Capistrano::Configuration.instance.load do
  default_run_options[:pty] = true
  ssh_options[:forward_agent] = true
  set :rvm_bin_path, "/usr/local/rvm/bin"
  
  set :user, 'root'
  set :group, 'www-data'
  
  set :scm, :git
  set :scm_verbose, false
  set :git_enable_submodules, 1
  set :deploy_via, :remote_cache
  
  set :using_rvm, true
  
  set :rails_env, :production
  set :unicorn_config, "#{current_path}/config/unicorn.rb"
  set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"
  set :unicorn_socket, "#{current_path}/tmp/sockets/unicorn.sock"

  set :runner, 'www-data'
  servers = ["beta.starseeders.net"]

  servers.each do |server|
    role :web, server
    role :app, server
    role :db,  server, :primary => true
  end
end
