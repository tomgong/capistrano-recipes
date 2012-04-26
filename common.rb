def generate_from_template(template_to_get, remote_file_to_put)
#require 'erb'  #render not available in Capistrano 2
  template=File.read(File.expand_path("./lib/recipies/templates/#{template_to_get}"))
  buffer= ERB.new(template).result(binding)
  put buffer, remote_file_to_put
end

# instead of _cset
def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

namespace :deploy do
  task :install do
    run "#{sudo} apt-get -y update"
  end
end
after "deploy", "deploy:cleanup" # keep only the last 5 releases

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :stages, %w(production staging)
set :default_stage, 'staging'

require 'capistrano/ext/multistage'
  
set :scm, :git
set :scm_verbose, false
set :git_enable_submodules, 1
set :deploy_via, :remote_cache
set :enable_ssl, false
set :use_sudo, false
set :branch, "master"


set :rvm_path, "/home/deployer/.rvm/"
