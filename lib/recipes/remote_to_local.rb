Capistrano::Configuration.instance(:must_exist).load do
  task :db_remote_to_local do
    require 'yaml_db'
    run "cd #{current_release} && RAILS_ENV=\"production\" bundle exec rake db:dump"
    get("#{current_release}/db/data.yml", "./db/data.yml")
    get("#{current_release}/db/schema.rb", "./db/schema.rb")
  
    `rake db:load`
  end

  task :public_remote_to_local do
    archive = "/tmp/public-#{domain_application}.tar.gz"
    run "cd #{current_release} && tar chzf #{archive} public/"
    get archive, "./public.tar.gz"
  end

  task :public_local_to_remote do
    filename = `ls -tr public.tar.gz | tail -n 1`.chomp
    if filename.empty?
      logger.important "No public.tar.gz found"
    else
      if stage == 'production' then
        logger.important "local to production not allowed"
      else                        
        archive = "/tmp/public-#{domain_application}.tar.gz"
        upload("#{filename}", archive)
        run "tar xzvf #{archive} -C #{current_path}"
      end
    end
    
    logger.debug "command finished"
  end

  before 'remote_to_local', :db_remote_to_local
  before 'remote_to_local', :public_remote_to_local
  task :remote_to_local do
    `rm -r public/`
    `tar xzvf ./public.tar.gz`
  end
    
end