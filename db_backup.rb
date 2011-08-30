Capistrano::Configuration.instance.load do
  # backup postgres database into a database-agnostic file
  desc "Dumps target database db into an file"
  task :backup_db do
    run "cd #{current_release} && rvmsudo RAILS_ENV=\"production\" rake db:dump"
  end
  
  before 'deploy:migrate', :backup_db
end