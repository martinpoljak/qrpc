# encoding: utf-8

require "rubygems"

$:.push("./lib")
$:.unshift("./lib")

require "qrpc/protocol/json-rpc"
#require "json-rpc-objects/serializer/bson"
require "json-rpc-objects/serializer/json"
#require "json-rpc-objects/serializer/yaml"
#require "json-rpc-objects/serializer/psych"
#require "json-rpc-objects/serializer/marshal"
require "json-rpc-objects/serializer/msgpack"

class Foo
    def subtract(x, y)
        x - y + 5
    end
end


require "qrpc/server"
require "qrpc/locator/em-jack"

serializer = JsonRpcObjects::Serializer::JSON::new
protocol = QRPC::Protocol::JsonRpc::new(:serializer => serializer)
server = QRPC::Server::new(Foo::new, :synchronous, protocol)
server.listen! QRPC::Locator::EMJackLocator::new("test")
