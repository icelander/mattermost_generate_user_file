

def confirm
	puts "Proceed? (y or N)"
	STDOUT.flush
	confirm = gets.chomp

	return confirm.downcase.start_with? 'y'	
end