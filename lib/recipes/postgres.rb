Capistrano::Configuration.instance(:must_exist).load do
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
    task :backup_database do
      # read database config
      config = YAML.load_file("config/database.yml")
      adapter = config[stage.to_s]["adapter"]
      hostname = config[stage.to_s]["host"]
      username = config[stage.to_s]["username"]
      password = config[stage.to_s]["password"]
      database = config[stage.to_s]["database"]
    
      if adapter == "postgresql" && hostname == "localhost"
        run %Q{#{sudo} -u postgres pg_dump #{database} -f #{shared_path}/db_backups/dump-#{Time.now.strftime("%Y%m%d-%H%M")}.sql}
      else
        puts "cannot dump the database as it isn't localhost or driver ain't postgresql"
        exit
      end
    end
    before 'deploy:migrate', 'postgres:backup_database'
  end
  
  desc "Copy the remote database as pg_dump sql file to the local development environment backup dir"
    task :pg_remote_to_local, :roles => :db, :only => { :primary => true } do
      # First lets get the remote database config file so that we can read in the database settings
      tmp_db_yml = "/tmp/database.yml"
      get("#{current_path}/config/database.yml", tmp_db_yml)

      # load the production settings within the database file
      db = YAML::load_file("/tmp/database.yml")["#{stage}"]
      run_locally("rm #{tmp_db_yml}")

      filename = "#{application}_#{stage}.dump.#{Time.now.to_i}.sql.bz2"
      file = "/tmp/#{filename}"
      on_rollback {
        run "rm #{file}"
        run_locally("rm #{tmp_db_yml}")
      }
      run "pg_dump --clean --no-owner --no-privileges -U#{db['username']} -h localhost #{db['database']} | bzip2 > #{file}" do |ch, stream, out|
        ch.send_data "#{db['password']}\n" if out =~ /^Password:/
        puts out
      end
      run_locally "mkdir -p -v 'backups/'"
      get file, "backups/#{filename}"
      run "rm #{file}"
  end
  
  desc "Copy the latest backup to the local development database"
    task :pg_import_backup_local do
      filename = `ls -tr backups | tail -n 1`.chomp
      if filename.empty?
        logger.important "No backups found"
      else
        ddb = YAML::load_file("config/database.yml")["development"]
        logger.debug "Loading backups/#{filename} into local development database"
        ENV['PGPASSWORD'] = ddb['password']
        run_locally "bzip2 -cd backups/#{filename} | psql -U #{ddb['username']} -d #{ddb['database']}"
        logger.debug "command finished"
      end
  end
  
  desc "Copy the latest locally stored backup to the designated environment"
    task :pg_import_local_backup_to_remote do
      filename = `ls -tr backups | tail -n 1`.chomp
      if filename.empty?
        logger.important "No backups found"
      else
        override_production = true
        if stage == 'production' then
          override_production = Capistrano::CLI.ui.agree "Do you really want to dump into production db (yes/[no])?" do |q|
            q.default = 'yes'
          end
        end

        if override_production then
          puts "copy pg backup file"
          upload("backups/#{filename}", "/tmp/#{filename}")
          puts "trying to restore backup #{filename} in env #{stage}"
          ddb = YAML::load_file("config/database.yml")["#{stage}"]
          ENV['PGPASSWORD'] = ddb['password']
          run "bzip2 -cd /tmp/#{filename} | psql -U #{ddb['username']} -d #{ddb['database']}" do |ch, stream, out|
            ch.send_data "#{ddb['password']}\n" if out =~ /^Password:/
            puts out
          end
          run "rm /tmp/#{filename}"
        end
        logger.debug "command finished"
      end
  end
  
end