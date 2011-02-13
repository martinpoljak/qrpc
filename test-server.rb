# encoding: utf-8
$:.push("./lib")

class Foo
    def subtract(x, y)
        x - y
    end
end


require "qrpc/server"
server = QRPC::Server::new(Foo::new)
server.listen! QRPC::Locator::new("test"), :max_jobs => 0
