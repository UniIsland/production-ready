#!/usr/bin/env ruby

deploy_to = {
    'refs/heads/master' => ['/path/to/repo', 'origin', 'master', 'supervisor program'],
    'refs/heads/live' => ['/path/to/repo', 'origin', 'live', 'supervisor program'],
}
#logfile = 'path/to/logfile'

old_dir = ENV['GIT_DIR']
ENV['RAILS_ENV'] = 'production'

STDIN.each do |line|
    oldrev, newrev, refname = line.split
    next unless deploy_to.has_key?(refname)

    ENV['GIT_DIR'] = old_dir
    needs_db_migrate = ! `git diff --numstat #{oldrev} #{newrev} -- db/schema.rb`.empty?
    needs_bundle_install = ! `git diff --numstat #{oldrev} #{newrev} -- Gemfile.lock`.empty?
    needs_assets_precompile = ! `git diff --numstat #{oldrev} #{newrev} -- app/assets/`.empty?

    dir, remote, branch, restart = deploy_to[refname]
    puts "deploying branch '#{branch}' to '#{dir}':"
    Dir.chdir(dir)
    ENV['GIT_DIR'] = "#{dir}/.git"
    puts `git reset --hard`
    puts `git pull #{remote} #{branch}`
    puts `bundle install --deployment` if needs_bundle_install
    puts `bundle exec rake db:migrate` if needs_db_migrate
    puts `bundle exec rake assets:precompile` if needs_assets_precompile
    puts `supervisorctl restart #{restart}`
end

