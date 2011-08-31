require "#{File.expand_path('./lib')}/recipies/common"

Capistrano::Configuration.instance.load do
  # generate a nginx configuration file
  task :configure_nginx do
    # run the template  
    generate_from_template("nginx.conf.tmpl", "/etc/nginx/sites-available.d/#{domain_application}")

    #add a symlink into sites enabled 
    sudo "ln -s -f /etc/nginx/sites-available.d/#{domain_application} /etc/nginx/sites-enabled.d/#{domain_application}"
  end
  
  namespace :nginx do
    task :start, :roles => :app, :except => { :no_release => true } do
      run "#{sudo} /usr/local/sbin/nginx -c /etc/nginx/nginx.conf -s reload"
    end
    
    task :stop, :roles => :app, :except => { :no_release => true } do 
      run "#{sudo} /usr/local/sbin/nginx -c /etc/nginx/nginx.conf -s reload"
    end

    task :reload, :roles => :app, :except => { :no_release => true } do
      run "#{sudo} /usr/local/sbin/nginx -c /etc/nginx/nginx.conf -s reload"
    end

    task :restart, :roles => :app, :except => { :no_release => true } do
      stop
      start
      run "#{sudo} /usr/local/sbin/nginx -c /etc/nginx/nginx.conf -s reload"    
    end
    
  end
  
  before 'deploy:restart', "configure_nginx"
  before 'deploy:start', "configure_nginx"
  
  after 'deploy:start', 'nginx:start'
  after 'deploy:stop', 'nginx:stop'
  after 'deploy:reload', 'nginx:reload'
  after 'deploy:graceful_stop', 'nginx:reload'
  after 'deploy:restart', 'nginx:reload'
end