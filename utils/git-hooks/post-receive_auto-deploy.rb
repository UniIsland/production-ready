#!/usr/bin/env ruby

branches = {
    'refs/heads/branch' => ['/repo/path', 'origin', 'live'],
}
logfile = 'path/to/logfile'
deploy = []

STDIN.each do |line|
    ref = line.split[0]
    if branches.has_key?(ref)
        deploy << ref
    end
end

deploy.uniq.each do |ref|
    target = branches[ref]
    puts "deploying changes to branch '#{target[2]}':"
    `cd #{target[0]} && unset GIT_DIR && git pull #{target[1]} #{target[2]} && bundle install --deployment && bundle exec rake db:migrate && bundle exec rake assets:precompile && supervisorctl restart cmusummit`
end

