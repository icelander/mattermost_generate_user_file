#!/usr/bin/ruby
require 'colorize'
require 'json'
require 'time'
require 'erb'
require 'ostruct'

def process_json_line(line)
	line = JSON.parse(line)
	output = {}

	line = line.each do |(k,v)| 
		key = k.to_sym

		case key
		when :ts
			output[:time] = Time.at(v)
		when :caller
			output[:callr] = v
		else 
			output[key] = v; 
		end
	end

	return output
end

def process_text_line(line)
	line_array = line.split(/\[(.+)\] \[(.+)\] (.+)/)
	# For some reason there's an empty string at the beginning
	line_array.shift()

	event_time = Time.parse(line_array[0])
	case line_array[1]
	when 'EROR'
		event_level = 'error'
	when 'DEBG'
		event_level = 'debug'
	when 'INFO'
		event_level = 'info'
	end

	event_msg = line_array[2]

	return {
		time: event_time,
		level: event_level,
		callr: nil,
		source: nil,
		msg: event_msg
	}
end

def output_line(line_hash)
	line_hash[:time] = line_hash[:time].strftime('%Y-%m-%d %H:%M:%S.%3N')

	line_format = <<~DOC
	<%= time %> <% if !level.nil? %><%= level.upcase %><% if !callr.nil? %><% end %>
	- Caller: <%= callr %><% end %><% if !source.nil? %>
	- Source: <%= source %><% end %>
	- Message <%= msg %>
	DOC
		
	output = erb(line_format, line_hash)

	case line_hash[:level]
	when 'error'
		puts output.red
	when 'debug'
		puts output.yellow
	when 'info'
		puts output.blue
	else
		puts output
	end
end

def erb(template, vars)
	ERB.new(template).result(OpenStruct.new(vars).instance_eval { binding })
end

file_path = ARGV[0]

File.readlines(file_path).each do |line|
	case line
	when /^{/
		line = process_json_line(line)
	else
		line = process_text_line(line)
	end

	output_line line
end