Capistrano::Configuration.instance(:must_exist).load do
  set(:shared_database_path) {"#{shared_path}/db"}

  namespace :sqlite3 do
    desc "Symlink for production.sqlite3 db"
    task :symlink_db do
      run "ln -nfs #{shared_database_path}/production.sqlite3 #{current_release}/db/production.sqlite3"
    end
 
    desc "Make a shared database folder"
    task :make_shared_folder, :roles => :db do
      run "mkdir -p #{shared_database_path}"
    end
  
    after "deploy:setup", "sqlite3:make_shared_folder"
    after "deploy:update_code", "sqlite3:symlink_db"
    before "deploy:migrate", "sqlite3:symlink_db"
  end
end