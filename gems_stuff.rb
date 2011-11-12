Capistrano::Configuration.instance.load do
  namespace :gems do
    desc "Install gems"
    task :install, :roles => :app do
      run "cd #{current_release} && rvmsudo bundle install"
    end
  
    desc "Install bundler"
    task :install_bundler do
      run "rvmsudo gem install bundler"
    end
  end

  after "deploy:update_code", "gems:install"
end