#!/usr/bin/env ruby

#require 'rubygems'
require 'linode'

api_key = 'APIKEY'
domain_id = 12345
resource_id = 54321

new_ip = `/sbin/ifconfig | grep "inet " | grep -v '127.0.0'`.split(' ')[1]

abort unless new_ip.match /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/

l = Linode.new :api_key => api_key
result = l.domain.resource.list :domainid => domain_id, :resourceid => resource_id
old_ip = result[0].target

print Time.new, '   '

if old_ip == new_ip
	puts "[no change] #{old_ip}"
else
	l.domain.resource.update :domainid => domain_id, :resourceid => resource_id, :target => new_ip
	puts "[updated] #{old_ip} -> #{new_ip}"
	warn "[updated] #{old_ip} -> #{new_ip}"
end

