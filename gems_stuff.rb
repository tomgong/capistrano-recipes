Capistrano::Configuration.instance(:must_exist).load do
  namespace :gems do
    desc "Install gems"
    task :install, :roles => :app do
      run "cd #{current_release} && bundle"
    end
  
    desc "Install bundler"
    task :install_bundler do
      run "gem install bundler"
    end
  end

  # TODO remove
  #after "deploy:finalize_update", "gems:install"
end
