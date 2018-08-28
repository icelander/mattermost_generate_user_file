<%= time %> <% if !level.nil? %><%= level.upcase %><% if !callr.nil? %><% end %>
	- Caller: <%= callr %><% end %><% if !source.nil? %>
	- Source: <%= source %><% end %>
	- Message <%= msg %>