# encoding: utf-8

$:.push("./lib")

require "rubygems"
require "qrpc/server"
require "qrpc/client"
require "qrpc/locator/evented-queue"
require "eventmachine"

#require "qrpc/generator/uuid"
require "qrpc/generator/object-id"

#require "json-rpc-objects/serializer/bson"
require "json-rpc-objects/serializer/json"
#require "json-rpc-objects/serializer/yaml"
#require "json-rpc-objects/serializer/psych"
#require "json-rpc-objects/serializer/marshal"
require "json-rpc-objects/serializer/msgpack"

EM::run do

    generator = QRPC::Generator::ObjectID::new
    queue = QRPC::Locator::EventedQueueLocator::new("test")

    ###############
    # Server
    ###############
    
    class Foo
        def subtract(x, y)
            x - y
        end
    end

    server = QRPC::Server::new(Foo::new, :synchronous, JsonRpcObjects::Serializer::MessagePack::new)
    server.listen! queue
    
    ###############
    # Client
    ###############
    
    serializer = JsonRpcObjects::Serializer::MessagePack::new
    client = QRPC::Client::new(queue, generator, serializer)
#    puts client.inspect

#    client.something_bad do |i|
#        puts i
#    end

    count = 0

    make = Proc::new do
        client.subtract(2, 3) do |i|
            #puts "x", i
            if i == -1
                count += 1
            end
        end
        #count += 1  
        #p queue.queue
        if count < 100000
            EM::next_tick do
                make.call()
            end
        else
            EM::stop
        end
    end
    
    make.call()
    
#    client.subtract(3, 2) do |i|
#        puts i
#    end
end
