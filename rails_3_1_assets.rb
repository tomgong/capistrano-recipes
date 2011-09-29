Capistrano::Configuration.instance.load do
  before :"deploy:symlink", :"deploy:assets";

  namespace :deploy do
    desc "Compile asets"
    task :assets do
      run "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:precompile"
    end
  end
end
