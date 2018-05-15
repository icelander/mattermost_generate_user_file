#!/usr/bin/ruby

require 'json'
require 'pp'
require 'etc'
require 'down'
require 'uri'


require_relative 'lib/command_line.rb'

## TODO
# => Log all output and interaction so you can archive all the things
# => => 

puts "Hi there! I'm going to help you upgrade Mattermost. Can you tell me the path where you have Mattermost installed?"
puts "If it's /opt/mattermost just push enter."
STDOUT.flush
mattermost_path = gets.chomp

if mattermost_path.empty?
	mattermost_path = '/opt/mattermost'
end
# TODO is there a more fault tolerant way of doing this?
config_path = "#{mattermost_path}/config/config.json"
puts "Loading config file from #{config_path}"

STDOUT.flush
confirm or puts "Okay, cancelling"

# TODO Add sanity check to make sure this path is, you know, a Mattermost path
# TODO Break this out into a method
begin
	config_file = File.open("#{mattermost_path}/config/config.json", 'r').read
	config_hash = JSON.parse(config_file)
	pp config_hash
rescue Exception => e
	pp e
end

def get_download_path(config_hash)
	# First I have to get https://about.mattermost.com/download/
	uri = URI.parse('https://about.mattermost.com/download/')
	file = uri.open
	# Next I have to get Find "Latest Release: (\d.\d.\d)\n"
	parts = file.read.match(/Latest Release: (\d\.\d\.?\d?)/)

	# Latest Version
	latest_version = parts[1]

	# Next get team or enterprise

	# If the license file is empty it's reasonable to expect that this is Team Edition
	if config_hash['ServiceSettings']['LicenseFileLocation'].empty?
		edition = "Team"
	else
		edition = "Enterprise"
	end

	puts "Specify Mattermost Enterprise or Team Edition"
	puts "Press enter for #{edition} Edition"
	STDOUT.flush
	selected_edition = gets.chomp.downcase

	if selected_edition.empty? or selected_edition.include? edition.downcase
		selected_edition = edition.downcase
	end


	# TODO - Get the ops to put these on reasonable paths. What is this?
	if selected_edition.include? 'team'
		download_path = "https://releases.mattermost.com/#{latest_version}/mattermost-team-#{latest_version}-linux-amd64.tar.gz"
	else
		download_path = "https://releases.mattermost.com/#{latest_version}/mattermost-#{latest_version}-linux-amd64.tar.gz"
	end

	return {:version => latest_version, :download_path => download_path}
end

download_info = get_download_path(config_hash)
latest_mattermost_version = download_info[:version]
download_path = download_info[:download_path]

puts "Download version #{latest_mattermost_version} via #{download_path}?"
puts "Proceed? (y or N)"
STDOUT.flush
confirm = gets.chomp
if !confirm.downcase.start_with? 'y'
	abort
end
confirm = nil

# TODO Download the file with a progress bar
# TODO WTF Ruby with your not verifying SSL certs?

# TODO Get the user and group for the files in the directory

install_user = Etc.getpwuid(File.stat(config_file).uid).name
install_group = Etc.getgrgid(File.stat(config_file).gid).name

puts "Enter the install user, or push enter to us #{install_user}"
STDOUT.flush
user = gets.chomp

if user.empty?
	user = install_user
end

puts "Enter the install group, or push enter to us #{install_group}"
STDOUT.flush
group = gets.chomp

if group.empty?
	group = install_group
end

=begin
# 0. Make a backup

	1. Backup Everything you change
	2. Ask if they want a database backup, too, while we're at it
	2. Explain to the user that they need to back up their databases and files because that's just smart
=end


# The command we're replicating is 
# sudo mv {install-path}/mattermost {install-path}/{mattermost-back-YYYY-MM-DD}
# TODO: Specify the backup file name
backup_file_name = "mattermost-back-#{Time.now.strfrtime("%Y-%m-%d")}"
puts "Backing up to #{backup_file_name}"

=begin


Then copy the files over

# sudo cp -r mattermost {install-path}


# Finally, clean up
	
=end

# TODO delete downloaded version of Mattermost after confirmation