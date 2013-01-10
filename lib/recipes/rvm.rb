Capistrano::Configuration.instance(:must_exist).load do
  set :rvm_type, :system
  set :rvm_install_ruby, :install # only install ruby if needed

  # TODO remove rvm 
  #before 'deploy:install', 'rvm:install_rvm'
  #before 'deploy:setup', 'rvm:install_ruby'

  set :rvm_path, "/home/deployer/.rvm/"
end