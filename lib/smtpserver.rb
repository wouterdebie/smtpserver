# = net/smtpserver.rb
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
# This class serves as a really simple SMTP (RFC821) server
# It's a port of the Perl Net::SMTP::Server, by MacGyver (aka Habeeb J. Dihu)
#
# Author::      Wouter de Bie (mailto@ruby@evenflow.nl)
# Copyright::   Copyright (c) 2007 Wouter de Bie
# License::     Distributes under the same terms as Ruby
module Net

# The Net::SMTPServer implements an RFC 821 compliant SMTP
# server, completely in Ruby. 
#
# Creating a new server works as following:
#  server = Net::SMTPServer.new(:hostname=>'127.0.0.1', :port=>25)
#
# This creates a new SMTPServer. Both :hostname and :port are optional
# and default to the current hostname and the standard SMTP port 25/tcp.
# A typical implementation looks something like this:
#
#  require 'smtpserver'
#  require 'smtpserverclient'
#
#  server = Net::SMTPServer.new(:hostname=>'127.0.0.1', :port=>25)
#  while conn = server.accept
#       client = Net::SMTPServerClient(conn)
#       client.process
#       puts client.from
#       client.to.each {|x| puts x}
#       puts message
#  end
#  server.close
#
# SMTPServer doesn't perform any checks or processing for the user.

class SMTPServer
  require 'socket'
  include Socket::Constants
  attr_reader :hostname, :port

  # Create a new SMTPServer
  # params take :hostname and :port
  def initialize(params=nil)
	if params.nil?
		@host = Socket.gethostname
		@port = 25
	else
	    @host = (params[:hostname]) ? params[:hostname] : Socket.gethostname  
	    @port = (params[:port]) ? params[:port] : 25 
	end
	puts @host
	puts @port 
	@server_socket = TCPServer.new(@host,@port)
	@server_socket.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
  end

  # Open the socket
  def accept
	@server_socket.accept
  end

  # Close the socket
  def close
	@server_socket.close
  end
  

end

end
