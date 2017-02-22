
task :default do
    sh "rake -T"
end

desc "release the app to prod"
task :release do
    remote = "reednj@paint.reednj.com"
    commands = ["cd so.reednj.com", "git reset --hard", "rake build"]
    sh "git push #{remote}:so.reednj.com/ master"
    sh "ssh #{remote} \"#{commands.join ';'}\""
end

desc "build the webapp on prod"
task :build => [:data, :config, :restart] do
    puts 'build complete'
end

directory "tmp"

task :restart => "tmp" do |t|
    touch "tmp/restart.txt"
end

task :config do |t|
    home = '/home/reednj'
    config = File.join home, 'code/config_backup/so'
    sh "cp #{config}/* ./lib"
end

file "data" do |t|
    sh "ln -s ~/#{t.name}"
end
