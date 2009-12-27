#!/usr/bin/ruby

require 'smtpserver'
require 'smtpserverclient'

	server = Net::SMTPServer.new(:hostname=>'127.0.0.1')
while conn = server.accept

	client = Net::SMTPServerClient.new(conn)
	client.process
	puts "Done processing"
	puts client.from
	puts client.to
	puts client.message
end
	server.close
