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

# as bash is run in non-interactive mode, set the rbenv path by
# hand
set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

# only recompile assets if they have changed
namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
end
