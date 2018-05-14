#!/usr/bin/ruby

puts "Hi there! I'm going to help you upgrade Mattermost. Can you tell me the path where you have Mattermost installed?"
puts "If it's /opt/mattermost just push enter."
STDOUT.flush
mattermost_path = gets.chomp

puts "Alright, I'm using #{mattermost_path}"
