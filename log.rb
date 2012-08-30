namespace :log do
  desc "Tail all application log files"
  task :tail do
    run "tail -f #{shared_path}/log/*.log" do |channel, stream, data|
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end

  desc "Install log rotation script; optional args: days=7, size=5M, group (defaults to same value as :user)"
  task :setup do
    rotate_script = %Q{#{shared_path}/log/#{stage}.log {
daily
rotate #{ENV['days'] || 7}
size #{ENV['size'] || "5M"}
compress
create 666 #{user} #{ENV['group'] || user}
dateext
missingok
copytruncate
}}
    put rotate_script, "#{shared_path}/logrotate_script"
    run "#{sudo} cp #{shared_path}/logrotate_script /etc/logrotate.d/rails_#{application}"
    run "rm #{shared_path}/logrotate_script"
  end
end

after 'deploy:setup', 'log:setup'
