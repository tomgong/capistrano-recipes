
# TODO: split up in separate tasks
namespace :deploy do

  task :initial_setup, :roles => [:db, :app] do
    
    # create gemset
    ruby_version = rvm_ruby_string.split("@")[0]
    gemset = rvm_ruby_string.split("@")[1]
    run "rvm use #{ruby_version} && rvm gemset create #{gemset}"
    
    # install bundler
    run "rvm use #{rvm_ruby_string} && gem install bundler"
    
    # read database config
    config = YAML.load_file("config/database.yml")
    adapter = config[stage.to_s]["adapter"]
    hostname = config[stage.to_s]["host"]
    username = config[stage.to_s]["username"]
    password = config[stage.to_s]["password"]
    database = config[stage.to_s]["database"]
    
    if adapter == "postgresql" && hostname == "localhost"
      # create database-user
      # TODO: check if the user exists beforehands
      run "sudo -u postgres /usr/bin/psql -Upostgres -c \"CREATE ROLE #{username} WITH PASSWORD '#{password}' LOGIN\" template1"
      run "sudo -u postgres createdb #{database}"
    else
      raise "cannot configure the database as it isn't localhost?"
    end
  end
end
