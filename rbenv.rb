Capistrano::Configuration.instance(:must_exist).load do
  namespace :rbenv do
    task :install_ruby do
      # TODO: make version configurable
      run "rbenv install 1.9.3-p286"
      run "rbenv global 1.9.3-p286"
      run "gem install bundler"
      run "rbenv rehash"
    end
    after "rbenv:install", "rbenv:install_ruby"

    task :install do
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install git build-essential zlib1g-dev libreadline5-dev libssl-dev"
      run "git clone git://github.com/sstephenson/rbenv.git ~/.rbenv"
      run "echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' >> ~/.bash_profile"
      run "echo 'eval \"$(rbenv init -)\"' >> ~/.bash_profile"
      run "git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build"
    end
    after "deploy:install", "rbenv:install"
  end
end
