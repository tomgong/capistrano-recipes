namespace :monit do
  desc "Install Monit"
  task :install do
    run "#{sudo} apt-get -y install monit"
  end
  after "deploy:install", "monit:install"

  desc "Setup Monit configuration"
  task :setup do
    generate_from_template "monit.conf.erb", "/tmp/#{application}.conf"
    run "#{sudo} mv /tmp/#{application}.conf /etc/monit/conf.d/"
    syntax
    restart
  end
  after "deploy:setup", "monit:setup"

  %w[start stop restart syntax].each do |command|
    desc "Run Monit #{command} script"
    task command do
      run "#{sudo} /etc/init.d/monit #{command}"
    end
    after "deploy:#{command}", "unicorn:#{command}"
  end
end
