# encoding: utf-8

require "rubygems"
$:.push("./lib")

class Foo
    def precall
        puts "precall"
    end
    
    def subtract(x, y)
        puts "call"
        x - y
    end
    
    def postcall
        puts "postcall"
    end
end


require "qrpc/server"
server = QRPC::Server::new(Foo::new)
server.listen! QRPC::Locator::new("test"), :max_jobs => 0
