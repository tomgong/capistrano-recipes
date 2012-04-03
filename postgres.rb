namespace :postgres do
  task :install, roles: :db do
    run "#{sudo} add-apt-repository ppa:pitti/postgresql"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install postgresql libpq-dev"
  end
  after "deploy:install", "postgres:install"

  task :create_database, :roles => [:db] do
    # read database config
    config = YAML.load_file("config/database.yml")
    adapter = config[stage.to_s]["adapter"]
    hostname = config[stage.to_s]["host"]
    username = config[stage.to_s]["username"]
    password = config[stage.to_s]["password"]
    database = config[stage.to_s]["database"]
    
    if adapter == "postgresql" && hostname == "localhost"
      # create database-user
      run %Q{#{sudo} -u postgres psql -c "create user #{username} with password '#{password}';"}
      run %Q{#{sudo} -u postgres psql -c "create database #{database} owner #{username};"}
    else
      puts "cannot configure the database as it isn't localhost or driver ain't postgresql"
      exit
    end

    run "#{sudo} mkdir -p #{shared_path}/db_backups" 
    run "#{sudo} chown postgres:postgres #{shared_path}/db_backups"
  end
  after "deploy:setup", "postgres:create_database"

  desc "Dumps target database db into an file"
  task :database do
    # read database config
    config = YAML.load_file("config/database.yml")
    adapter = config[stage.to_s]["adapter"]
    hostname = config[stage.to_s]["host"]
    username = config[stage.to_s]["username"]
    password = config[stage.to_s]["password"]
    database = config[stage.to_s]["database"]
    
    if adapter == "postgresql" && hostname == "localhost"
      run %Q{#{sudo} -u postgres pg_dump #{database} -f #{shared_path}/db_backups/dump-#{Time.now.strftime("%Y%m%d-%H%M")}.sql;"}
    else
      puts "cannot dump the database as it isn't localhost or driver ain't postgresql"
      exit
    end
  end
  before 'deploy:migrate', 'backup:database'
end
