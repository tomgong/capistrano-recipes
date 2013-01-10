# TODO: run those commands as root (and not as normal user)

Capistrano::Configuration.instance(:must_exist).load do
  namespace :base_setup do

	  task :prepare_root_stuff do
		  logger.info "full deploy (as root) tasks"
  	end

    task :copy_add_apt_repository do
      generate_from_template 'add-apt-repository', '/usr/local/bin/add-apt-repository'
      run "chmod +x /usr/local/bin/add-apt-repository"
    end
    after "base_setup:prepare_root_stuff", "base_setup:copy_add_apt_repository"

    task :install_sudo do
      run "apt-get update"
      run "apt-get -y install sudo"
      # TODO/IDEA: add sudo rules for user
    end
    after "base_setup:prepare_root_stuff", "base_setup:install_sudo"

    task :install_base_gem_dependencies do
      run "apt-get -y install libmagickwand-dev libsqlite3-dev"
    end
    after "base_setup:prepare_root_stuff", "base_setup:install_base_gem_dependencies"
  end
end
