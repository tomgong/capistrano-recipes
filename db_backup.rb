# backup postgres database into a database-agnostic file
namespace :backup do
  desc "Dumps target database db into an file"
  task :database do
    run "cd #{current_release} && rvmsudo RAILS_ENV=\"production\" rake db:dump"
  end
  before 'deploy:migrate', 'backup:database'
end
