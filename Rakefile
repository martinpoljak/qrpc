# encoding: utf-8
require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'jeweler2'

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "qrpc"
  gem.homepage = "http://github.com/martinkozak/qrpc"
  gem.license = "MIT"
  gem.summary = 'Queued RPC client and server. Works as normal RPC server, but through queue interface, so allows highly scalable, distributed and asynchronous remote API implementation and fast data processing. It\'s based on EventMachine and typically on Beanstalk, so it\'s fast and thread safe.'
  gem.post_install_message = "\nQRPC: API of the 0.9.x version (and 1.0 in future) is partialy incompatible with the older versions. Modifications of your current applications may be necessary for upgrading them to the latest version. \n\n"
  gem.email = "martinkozak@martinkozak.net"
  gem.authors = ["Martin Kozák"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new
