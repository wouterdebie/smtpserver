require 'rubygems'
SPEC = Gem::Specification.new do |s|
	s.name		= "SMTPServer"
	s.version	= "0.1"
	s.author	= "Wouter de Bie"
	s.email		= "ruby@evenflow.nl"
	s.homepage	= "http://www.evenflow.nl"
	s.platform	= Gem::Platform::RUBY
	s.summary	= "Simple native Ruby SMTP server"
	candidates	= Dir.glob("{bin,docs,lib,test}/**/*")
	s.files		= candidates.delete_if do |item|
					item.include?(".svn") || item.include?("rdoc")
				  end
	s.require_path	= "lib"
	s.autorequire	= "smtpserver"
	s.has_rdoc		= true
	s.extra_rdoc_files = ["README"]
end
