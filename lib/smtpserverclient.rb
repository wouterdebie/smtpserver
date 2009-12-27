# = net/smtpserverclient.rb
# 
# Copyright (c) 2007 Wouter de Bie
#
# Written & maintained by Wouter de Bie
#
#
# This program is free software. You can re-distribute and/or
# modify this program under the same terms as Ruby itself,
# Ruby Distribute License or GNU General Public License.
#
# This class serves as the client handler for Net::SMTPServer 
# It's a port of the Perl Net::SMTP::Server, by MacGyver (aka Habeeb J. Dihu)
#
# Author::		Wouter de Bie (mailto:ruby@evenflow.nl)
# Copyright::  	Copyright (c) 2007 Wouter de Bie
# License::		Distributes under the same terms as Ruby

module Net

# The Net::SMTPServerClient class implements all the session handling
# required for a Net::SMTPServerClient connection. The following gives an example
# of its use together with Net::SMTPServer:
# 
#  require 'smtpserver'
#  require 'smtpserverclient'
# 
#  server = Net::SMTPServer.new(:hostname=>'127.0.0.1', :port=>25)
#  while conn = server.accept
#		client = Net::SMTPServerClient(conn)
#		client.process
#		puts client.from
#		client.to.each {|x| puts x}
#		puts message
#  end
#  server.close
#
# Net::SMTPServerClient accepts one argument that must be a Socket that
# will be used for all communication.
#
# Once you have the new client session, simply call the process() method.
# This processes an SMTP transaction. This may appear to hang, especially if
# there is a large amount of data being sent. Once the method returns, the
# server will have processed an entire SMTP transaction and is ready to continue
#
# Once process() returns, the following attributes have been filled:
#
# * @to	This is an array containing the intended recipients for this message. There may be multiple recipients for any given message
# * @from The sender of the given message
# * @message The acutal message data.


class SMTPServerClient
  require 'socket'
  attr_accessor :to, :from, :message

  # Setup the object. The socket can ofcourse be reused, so we check that here.
  def initialize(socket)
    @cmds = ['data','expn','helo','help','mail','noop','quit','rcpt','rset','vrfy']
	
	if socket != @socket
		socket.puts "220 Ruby Net::SMTPServer Ready.\r\n" 
	end
	@socket = socket
	@to = []
	@message = ""
  end


  # Start processing the incoming requests
  def process
	
	# Get line from the socket
  	while input = @socket.gets
		
		# Remove stupid whitespace in front or at the end
		input.gsub!(/^\s+/,'')
		input.gsub!(/\s+$/,'')

		# Check if we can actually do something with the input
		if input.empty? then
			bad_input
			next
		end

		# Get command and arguments from input
		a = input.split(/\s+/,2)
		cmd = a[0]
		args = a[1]
		cmd.downcase!	

		# Barf when we don't know the command
		if !@cmds.include?(cmd) then
			bad_input
			next
		end

		# Call method based on command
		method(cmd).call(args)
		
		# Return if the message is not empty (means we received an email)
		return unless @message.empty? 

		# Return if the socket is closed with QUIT
		return if @closed
	end
  end

private
  
  # RFC 821 requires us to send out everything with CRLF. Therefore we use this method
  def put(string)
	@socket.puts string + "\r\n"
  end

  # Reset the session
  def rst
	@from = nil
	@to = []
	@message = ""
	put "250 Fine fine."
  end

  # Send bad input message to the client
  def bad_input
	put "500 Syntax error."
  end

  # Get the from address
  def mail(args)
	fromto(args)
  end

  # Get the to address
  def rcpt(args)
	fromto(args)
  end

  # Since parsing FROM: and TO: is the same thing, we use this one method
  def fromto(args)

	# Split the type and arguments
	a = args.split(/:\s*/,2)
	cmd = a[0].downcase
	address = a[1].chomp
	
	# Barf if
	if address.nil? || address.empty?
		put "501 Syntax error in arguments."
		return
	end

	# Either fill @from or @to
	case cmd
		when "to" then @to << address.gsub(/[\<,\>]/,"")
		when "from" then @from = address.gsub(/[\<,\>]/,"")
	end
	
	put "250 Ok...got it."

  end

  # Get the data from the socket and put it in @message
  def data(args=nil)

	# Check if we have both from and to adresses
	if @from.nil? then
		put "503 Missing FROM: address"
		return
	end
	if @to.empty? then
		put "503 Missing TO: address"	
		return
	end	

	put "354 Feed me.."

	# Keep reading from the socket until we find a dot
	while indata = @socket.gets
		if indata =~ /^\.\r\n$/
			put "250 data OK"
			return
		end
		
		# RFC 821 Compliance
		indata.gsub!(/^\.\./,".")
		@message << indata
	end
	put "550 mhh.. shouldn't be here"

  end

  # We don't support EXPN
  def expn(args=nil)
	noway
  end

  # Just returns OK
  def noop(args=nil)
	put "250 Ok."
  end

  # We don't support VRFY
  def vrfy(args=nil)
	noway
  end

  def noway(args=nil)
	put "252 Nice try."
  end

  # Quit and close the socket
  def quit(args=nil)
	put "221 Bye!"
	@socket.close
	@closed = true
  end

  # Reply to the HELO command
  def helo(args=nil)
	put "250 " + Socket.gethostname
	@helo = true
  end

end
end
