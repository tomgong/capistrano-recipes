Capistrano::Configuration.instance(:must_exist).load do

	set_default(:backup_postgres_socket_path, "/var/run/postgres")
	set_default(:backup_encryption_password) { Capistrano::CLI.password_prompt "Choose an encryption password: " }
	set_default(:backup_backup_server_user) { Capistrano::CLI.ui.ask "What is your backup server's username? " }
	set_default(:backup_backup_server_pass)  { Capistrano::CLI.password_prompt "What is your backup server's password? " }
	set_default(:backup_backup_server_host)  { Capistrano::CLI.ui.ask "What is your backup server's hostname? " }

	namespace :backup do
	  desc "Install the backup gem."
	  task :install do

	  	sftpbackup = Capistrano::CLI.ui.agree "Do you want backups via sftp ([yes]/no)?" do |q|
	  		q.default = 'yes'
	  	end

	  	localbackup = Capistrano::CLI.ui.agree "Do you want local backups ([yes]/no)?" do |q|
	  		q.default = 'yes'
	  	end

	  	set :sftpbackup, sftpbackup
	  	set :localbackup, localbackup

	  	if sftpbackup || localbackup then 

	  		run "gem install backup"
	  		run "gem install whenever"

	  		if sftpbackup then
	  			run "gem install net-ssh -v '~> 2.3.0'"
	  		end

      		run "rbenv rehash"

			run "mkdir -p #{shared_path}/config/backup/models"	    	
	    	generate_from_template "backup/daily_backup.rb.erb", "#{shared_path}/config/backup/models/daily_backup.rb"
	    	generate_from_template "backup/config.rb.erb", "#{shared_path}/config/backup/config.rb"
	    	generate_from_template "backup/backup.yml.erb", "#{shared_path}/config/backup/backup.yml"
	    
	    	# setting up cronjob
	    	generate_from_template "backup/schedule.rb.erb", "#{shared_path}/config/backup/schedule.rb"
	    	run "whenever -f #{shared_path}/config/backup/schedule.rb --update-crontab"
	    end

	  end
	  after "deploy:install", "backup:install"

	  desc "Symlink the backup.yml file to the current release"
	  task :symlink, roles: :app do
	    run "ln -nfs #{shared_path}/config/backup/backup.yml #{release_path}/config/backup.yml"
	  end
	  after "deploy:finalize_update", "backup:symlink"
	end

end