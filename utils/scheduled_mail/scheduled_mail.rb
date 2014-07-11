#!/usr/bin/env ruby
# encoding: UTF-8

#require "mail"
require "yaml"
#require 'pry'

Arg = ARGV[0]
ConfFile = "#{ENV['HOME']}/.config/scheduled_mail.yaml"
CrontabFile = "/etc/cron.d/scheduled_mail"
RubyPath = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name']) \
  .sub(/.*\s.*/m, '"\&"')
ScriptPath = File.expand_path $0

def update_cron_d(conf)
  user = ENV['USER']
  tmpFile = `mktemp`.strip
  open(tmpFile, "wb") do |f|
    f.puts "## This file is auto-generated. Edits will be overwritten. Update it's content with scheduled_mail.rb"
    conf[:jobs].each do |job,opts|
      next unless opts[:enabled]
      f.puts "#{opts[:when]} #{user} #{RubyPath} #{ScriptPath} #{job}"
    end
  end
  `sudo cp #{tmpFile} #{CrontabFile}; rm #{tmpFile}`
end
def sendmail(opts, smtp)
  require "mail"
  mail = Mail.new do
    from opts[:from]
    to opts[:to]
    subject opts[:subject] % Time.new.strftime("%b %-d")
    reply_to opts[:reply_to] if opts.has_key? :reply_to
    body opts[:body] + opts[:signature]
  end
  mail.charset = opts[:charset]
  mail.delivery_method :smtp, smtp

  mail.deliver!
end

conf = YAML.load_file ConfFile

if Arg.nil? or Arg == '--list'
  puts "Listing all configured emails:"
  conf[:jobs].each do | job, opts|
    enabled = (opts[:enabled] ? 'Enabled: ' : 'Disabled:')
    puts "  #{enabled} #{opts[:when]} - #{job}"
  end
elsif Arg == '--update'
  update_cron_d conf
else
  abort "[Error] #{Arg}: job not found." unless conf[:jobs].has_key? Arg

  opts = conf[:jobs][Arg]
  sendmail opts, conf[:smtp]
end
