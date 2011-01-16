# encoding: utf-8
$:.push("./lib")

class Foo
    def bar
        return "Hello, world."
    end
end


require "qrpc/server"
server = QRPC::Server::new(Foo::new)
server.listen! QRPC::Locator::new("test")
