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

def get_download_url(config_hash)
	# First I have to get https://about.mattermost.com/download/
	uri = URI.parse('https://about.mattermost.com/download/')
	file = uri.open
	# Next I have to get Find "Latest Release: (\d.\d.\d)\n"
	parts = file.read.match(/Latest Release: (\d+\.\d*\.?\d*)/)

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
		download_url = "https://releases.mattermost.com/#{latest_version}/mattermost-team-#{latest_version}-linux-amd64.tar.gz"
	else
		download_url = "https://releases.mattermost.com/#{latest_version}/mattermost-#{latest_version}-linux-amd64.tar.gz"
	end

	return {:version => latest_version, :download_url => download_url}
end

download_info = get_download_url(config_hash)
latest_mattermost_version = download_info[:version]
download_url = download_info[:download_url]

puts "Download version #{latest_mattermost_version} via #{download_url}?"

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

backup_file_name = "mattermost-back-#{Time.now.strfrtime("%Y-%m-%d")}"
backup_file_path = Dir.pwd + '/' + backup_file_name

puts "Should I backup the database as well?"
backup_db = confirm("y or N", 'y')

if backup_db
	backup_str = 'Yes'
else
	backup_str = 'No'
end

puts "Finally, should I backup the data directory?"
backup_data = confirm('y or N', 'y')

if backup_db
	backup_db_str = 'Yes'
else
	backup_db_str = 'No'
end

puts <<-CONFIRMATION
Thanks for that information. Here's the values you provided. Please double check them before you proceed.

 - Mattermost Path #{mattermost_path}
 - Mattermost Version: v. #{latest_mattermost_version}
 - Download URL: #{download_url}
 - Backup File Path: #{backup_file_path}.tgz
 - Backup Database: #{backup_db_str}
 - Backup Data: #{backup_data_str}

To proceed with the upgrade type "Proceed" and push enter

CONFIRMATION
STDOUT.flush
confirmation = gets.chomp


if confirmation.downcase != 'proceed'
	abort "Aborting upgrade"
end


Dir.mkdir backup_file_path

if backup_db
	
end

=begin
# 0. Make a backup

	1. Backup Everything you change
	
	2. Explain to the user that they need to back up their databases and files because that's just smart
=end


# The command we're replicating is 
# sudo mv {install-path}/mattermost {install-path}/{mattermost-back-YYYY-MM-DD}
# TODO: Specify the backup file name

puts "Backing up to #{backup_file_name}"

=begin


Then copy the files over

# sudo cp -r mattermost {install-path}


# Finally, clean up
	
=end

# TODO delete downloaded version of Mattermost after confirmation