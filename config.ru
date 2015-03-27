require 'base64'
require 'unirest'

@token = ENV['GITHUB_ACCESS_TOKEN']

run Proc.new { |env|

	req = Rack::Request.new(env)
	parts = req.path_info.split '/'

	user = parts[1]
	repo = parts[2]
	version = parts[3]
	path = parts[4..parts.length].join '/'

	url = 'https://api.github.com/repos'
	url = "#{url}/#{user}/#{repo}/contents/#{path}?ref=#{version}&access_token=#{@token}"
	response = Unirest.get url
	content = Base64.decode64 response.body['content']

	[200, {'Content-Type' => 'text/plain'}, content]
}
