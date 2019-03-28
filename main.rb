#!/usr/bin/env ruby
require 'yaml'
require 'json'
require './lib/mattermost_api.rb'

allowed = ['email','ldap']
auth_method = ARGV[0]

if !allowed.include? auth_method
	puts "Error: Invalid auth method. Please choose email or ldap"
	abort
end



$config = YAML.load(
	File.open('conf.yaml').read
)

mm = MattermostApi.new($config['mattermost_api']['url'],
				 	   $config['mattermost_api']['auth_token'])

users = mm.get_users_by_auth(auth_method)

puts JSON.pretty_generate(users)