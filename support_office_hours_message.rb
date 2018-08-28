#!/usr/bin/env ruby

require Dir.pwd + '/lib/mattermost_api.rb'

$config = YAML.load(
	File.open('conf.yaml').read
)

mm_config = $config['mattermost_api']

mm = MattermostApi.new(mm_config['url'],
					   mm_config['username'],
					   mm_config['password'])


message = <<MSG
# Customer Support Office Hours Report

 - [Meeting Notes Here](https://docs.google.com/document/d/18pZzeobCB2c0PMBgDo5Rkpw8dJl8K7nVt3g5l5t3J3I/edit?usp=sharing)
 - [Recording Archive](https://drive.google.com/drive/folders/1vQRv2boncvAbhpbHynDepi-0DFCcJjOS?usp=sharing)
MSG

puts mm.post_to_channel(mm_config['team'], 'community', message)