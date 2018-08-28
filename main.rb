#!/usr/bin/env ruby

allowed = ['email','ldap']
auth_method = ARGV[0]

if !allowed.include? auth_method
	puts "Error: Invalid auth method. Please choose email or ldap"
	abort
end

require 'yaml'
require 'pp'
require 'json'
require './lib/mattermost_api.rb'

$config = YAML.load(
	File.open('conf.yaml').read
)



mm = MattermostApi.new($config['mattermost_api']['url'],
				 	   $config['mattermost_api']['username'],
				 	   $config['mattermost_api']['password'])

users = mm.get_users_by_auth(auth_method)

puts JSON.pretty_generate(users)