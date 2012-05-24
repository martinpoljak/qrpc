# encoding: utf-8

require "rubygems"

$:.push("./lib")
$:.unshift("./lib")
require "qrpc/client"
require "qrpc/locator/em-jack"
require "eventmachine"

#require "qrpc/generator/uuid"
require "qrpc/generator/object-id"

require "qrpc/protocol/json-rpc"
#require "json-rpc-objects/serializer/bson"
#require "json-rpc-objects/serializer/psych"
require "json-rpc-objects/serializer/json"
#require "json-rpc-objects/serializer/yaml"
#require "json-rpc-objects/serializer/marshal"
require "json-rpc-objects/serializer/msgpack"

EM::run do
    generator = QRPC::Generator::ObjectID::new
    locator = QRPC::Locator::EMJackLocator::new(:test)
    serializer = JsonRpcObjects::Serializer::JSON::new
    protocol = QRPC::Protocol::JsonRpc::new(:serializer => serializer)
    client = QRPC::Client::new(locator, generator, protocol)
#    puts client.inspect

#    client.something_bad do |i|
#        puts i
#    end

    count = 0

    make = Proc::new do
        client.subtract(2, 3) do |i|
            puts i
            if i == 4
                count += 1
            end
        end

        if count < 10
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

=begin
require "beanstalk-client"
require "json-rpc-objects/request"

b = Beanstalk::Pool::new(["localhost:11300"])
req1 = JsonRpcObjects::Request::create(:subtract, [2, 3], :id => "job1", :qrpc => { :version => "1.0", :client => :cc })
req2 = JsonRpcObjects::Request::create(:something_bad, nil, :id => "job2", :qrpc => { :version => "1.0", :client => :cc, :priority => 20 })

req1.serializer = JsonRpcObjects::Serializer::BSON::new
req2.serializer = JsonRpcObjects::Serializer::BSON::new

b.use("qrpc-test-input")
b.watch("qrpc-cc-output")
b.put(req1.serialize)
b.put(req2.serialize)

job = b.reserve
puts job.body
job.delete

job = b.reserve
puts job.body
job.delete
=end

=begin
100.times do
    b.put(req1.to_json)
    job = b.reserve
    puts job.body
    job.delete
end
=end
