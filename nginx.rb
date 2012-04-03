namespace :nginx do
  task :install do
    run "#{sudo} add-apt-repository ppa:nginx/stable"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install nginx"
  end
  after "deploy:install", "nginx:install"

  task :setup do
    # first move it into a temporary directory so we can move the file
    # through sudo. This allows us to deploy as non-root user
    generate_from_template("nginx.conf.tmpl", "/tmp/#{application}")
    run "#{sudo} mv /tmp/#{application} /etc/nginx/sites-enabled.d/#{application}"
    restart
  end
  after "deploy:setup", "nginx:setup"

  %w[start stop restart].each do |command|
    desc "#{command} nginx server"
    task command do
      run "#{sudo} /etc/init.d/nginx #{command}"
    end
  end
end
