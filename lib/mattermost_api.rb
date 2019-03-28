require 'httparty'

class MattermostApi
	include HTTParty

	format :json
	# debug_output $stdout
	
	def initialize(mattermost_url, token)
		@base_uri = mattermost_url + 'api/v4/'
		
		@options = {
			headers: {
				'Content-Type' => 'application/json',
				'User-Agent' => 'Mattermost-HTTParty'
			},
			# TODO Make this more secure
			verify: false
		}
		
		@options[:headers]['Authorization'] = "Bearer #{token}"
		@options[:body] = nil
	end

	def post_data(payload, request_url)
		options = @options
		options[:body] = payload.to_json

		self.class.post("#{@base_uri}#{request_url}", options)
	end

	def get_url(url)
		per_page = 200
		page = 0
		results = []

		loop do
			request_url = "#{url}?per_page=#{per_page}&page=#{page}"
			request = JSON.parse(self.class.get("#{@base_uri}#{request_url}", @options).to_s)

			results = results + request

			if request.length < per_page then break end
		end

		return results
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

end