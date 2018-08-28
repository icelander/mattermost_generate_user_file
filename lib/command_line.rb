

def confirm(message="Proceed? (y or N)", confirm_value='y')
	puts message
	STDOUT.flush
	confirm = gets.chomp

	return confirm.downcase.start_with? confirm_value
end