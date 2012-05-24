# encoding: utf-8

$:.unshift("./lib")
$:.push("./lib")

require "rubygems"
require "qrpc/server"
require "qrpc/client"
require "qrpc/locator/evented-queue"
require "qrpc/locator/em-jack"
require "eventmachine"

#require "qrpc/generator/uuid"
require "qrpc/generator/object-id"
require "qrpc/protocol/object"

#require "json-rpc-objects/serializer/bson"
require "json-rpc-objects/serializer/json"
#require "json-rpc-objects/serializer/yaml"
#require "json-rpc-objects/serializer/psych"
#require "json-rpc-objects/serializer/marshal"
require "json-rpc-objects/serializer/msgpack"

EM::run do
    generator = QRPC::Generator::ObjectID::new
    queue = QRPC::Locator::EventedQueueLocator::new("test")
    #queue1 = QRPC::Locator::EMJackLocator::new("test")
    #queue2 = QRPC::Locator::EMJackLocator::new("test")
    protocol = QRPC::Protocol::Object::new

    ###############
    # Server
    ###############
    
    class Foo
        def subtract(x, y)
            puts "response"
            x - y
        end
    end

    server = QRPC::Server::new(Foo::new, :synchronous, protocol)
    server.listen! queue
    
    ###############
    # Client
    ###############
    
    client = QRPC::Client::new(queue, generator, protocol)
#    puts client.inspect

#    client.something_bad do |i|
#        puts i
#    end

    count = 0

    make = Proc::new do
        puts "request"
        
        client.subtract(2, 3) do |i|
            puts "x", i
            count += 1
        end

        #count += 1  
        #p queue.queue

        if count < 7  
            EM::next_tick do
                make.call()
            end
        else
            #EM::stop
        end
    end
    
    make.call()
    
#    client.subtract(2, 3) do |i|
#        puts "x"
#        puts i
#    end
    
end
