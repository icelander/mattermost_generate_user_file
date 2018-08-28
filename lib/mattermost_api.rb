require 'httparty'
require 'time'
require 'digest'
require 'pp'


class MattermostApi
	include HTTParty

	format :json
	# debug_output $stdout
	
	def initialize(mattermost_url, login_id, password)
		@base_uri = mattermost_url + 'api/v4/'
		@login_id = login_id
		@password = password
		@tmp_file = '/tmp/' + Digest::MD5.hexdigest("#{login_id}#{password}")

		@options = {
			headers: {
				'Content-Type' => 'application/json',
				'User-Agent' => 'Mattermost-HTTParty'
			},
			# TODO Make this more secure
			verify: false
		}
		
		token = nil
		
		begin
			if File.file?(@tmp_file) && File.readable?(@tmp_file)
				token = JSON.parse(File.read(@tmp_file))
				if Time.now < Time.parse(token['expiration'])
					token = token['value']
				end
			end
		rescue Exception => e
			pp e
		end

		if token.nil?
			token = handle_login	
		end
		
		@options[:headers]['Authorization'] = "Bearer #{token}"
		@options[:body] = nil

	end

	def get_current_user
		get_url('users/me')
	end

	def post_data(payload, request_url)
		options = @options
		options[:body] = payload.to_json

		self.class.post("#{@base_uri}#{request_url}", options)
	end

	def send_direct_message(to_user, message)
		# Find the user ID
		to_id = get_user_by_name(to_user)['id']
		from_id = self.get_current_user['id']

		data = [to_id, from_id]
		channel = post_data(data, 'channels/direct')
		
		create_post(channel['id'], message)
	end

	def post_to_channel(team_name, channel_name, message)
		team_id = get_team_id(team_name)
		channel_id = get_channel_id_by_name(channel_name, team_id)['id']
		
		create_post(channel_id, message)
	end

	def get_channel_id_by_name(channel_name, team_id)
		
		get_url("teams/#{team_id}/channels/name/#{channel_name}")
	end

	def get_team_id(team_name)
		user_id = self.get_current_user['id']
		teams = self.get_url("users/#{user_id}/teams")

		teams.each do |team|
			if team['name'] == team_name || team['display_name'] == team_name
				return team['id']
			end
		end

		raise "Could not find team"
	end

	def get_user_by_name(username)
		JSON.parse(self.class.get("#{@base_uri}users/username/#{username}", @options).to_s)
	end

	def create_post(channel_id, message)
		data = {channel_id: channel_id, message: message}

		post_data(data, 'posts')
	end

	def get_url(url)
		JSON.parse(self.class.get("#{@base_uri}#{url}", @options).to_s)
	end

	private

	def handle_login
		login_options = @options
		login_options[:headers]['Content-Type' => 'application/x-www-form-urlencoded']
		login_options[:body] = {'login_id' => @login_id, 'password' => @password}.to_json

		login_response = self.class.post("#{@base_uri}users/login", login_options) 

		headers = login_response.headers

		token = headers['Token']

		cookie_hash = CookieHash.new

		login_response.get_fields('Set-Cookie').each do |c|
			cookie_hash.add_cookies(c)
		end
		
		token_data = {value: token, expiration: cookie_hash[:Expires]}

		if File.writable?(@tmp_file) || !File.file?(@tmp_file)
			File.write(@tmp_file, token_data.to_json)
		end

		token
	end
end