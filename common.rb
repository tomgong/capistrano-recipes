require 'capistrano'

def generate_from_template(template_to_get, remote_file_to_put)
  template=File.read("#{File.dirname(__FILE__)}/templates/#{template_to_get}")
  buffer= ERB.new(template).result(binding)
  put buffer, remote_file_to_put
end

# instead of _cset
def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

configuration = Capistrano::Configuration.respond_to?(:instance) ? Capistrano::Configuration.instance(:must_exist) : Capistrano.configuration(:must_exist)
configuration.load do

  # update apt database
  namespace :deploy do
    task :install do
      run "#{sudo} apt-get -y update"
    end
  end

  # keep only the last 5 releases
  after "deploy", "deploy:cleanup"

  default_run_options[:pty] = true
  ssh_options[:forward_agent] = true

  set :scm, :git
  set :scm_verbose, false
  set :git_enable_submodules, 1
  set :deploy_via, :remote_cache
  set :enable_ssl, false
  set :use_sudo, false
  set :branch, "master"

  # as bash is run in non-interactive mode, set the rbenv path by
  # hand
  set :default_environment, {
    'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
  }
  
end