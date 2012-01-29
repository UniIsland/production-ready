#!/usr/bin/env ruby

branches = {
    'refs/heads/master' => ['/home/www/cmusummit', 'origin', 'master'],
}
logfile = 'path/to/logfile'
deploy = []

STDIN.each do |line|
    ref = line.split[2]
    if branches.has_key?(ref)
        deploy << ref
    end
end

deploy.uniq.each do |ref|
    target = branches[ref]
    puts "deploying changes to branch '#{target[2]}':"
    puts `export RAILS_ENV=production && cd #{target[0]} && unset GIT_DIR && git reset --hard && git pull #{target[1]} #{target[2]} && bundle install --deployment && bundle exec rake db:migrate && bundle exec rake assets:precompile && supervisorctl restart cmusummit`
end

