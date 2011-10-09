# encoding: utf-8

require "rubygems"

$:.push("./lib")
#require "json-rpc-objects/serializer/bson"
#require "json-rpc-objects/serializer/json"
#require "json-rpc-objects/serializer/yaml"
#require "json-rpc-objects/serializer/psych"
#require "json-rpc-objects/serializer/marshal"
require "json-rpc-objects/serializer/msgpack"

class Foo
    def subtract(x, y)
        x - y
    end
end


require "qrpc/server"
server = QRPC::Server::new(Foo::new, :synchronous, JsonRpcObjects::Serializer::MessagePack::new)
server.listen! QRPC::Locator::new("test"), :max_jobs => 0
