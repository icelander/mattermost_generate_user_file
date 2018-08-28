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
		@tmp_file = './tmp/' + Digest::MD5.hexdigest("#{login_id}")

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

	def post_data(payload, request_url)
		options = @options
		options[:body] = payload.to_json

		self.class.post("#{@base_uri}#{request_url}", options)
	end

	def get_url(url)
		JSON.parse(self.class.get("#{@base_uri}#{url}", @options).to_s)
	end

	def get_users_by_auth(auth_method)
		users = self.get_url('/users')

		output_users = {}
		

		if auth_method == 'email'
			auth_method = ''
		end

		users.each do |user|
			if user['auth_service'] == auth_method
				output_users[user['email']] = user['username']
			end
		end

		return output_users
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