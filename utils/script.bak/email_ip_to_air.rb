#!/usr/bin/env ruby

record_file = '/tmp/pku_ipaddr'

new_ip = `/sbin/ifconfig eth0 | grep 'inet '`.split(' ')[1].split(':')[1]
old_ip = `touch #{record_file}; cat #{record_file}`.strip

abort unless new_ip.match /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/

if old_ip == new_ip
    puts "[no change] #{old_ip}"
else
    msg = "[updated] #{old_ip} -> #{new_ip}"
    puts `echo '#{msg}' | mail -s "gsm server ipaddr changed" air@pku.edu.cn`
    puts `echo #{new_ip} > #{record_file}`
    puts msg
    warn msg
end

