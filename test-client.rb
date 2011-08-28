# encoding: utf-8

require "rubygems"

$:.push("./lib")
require "qrpc/client"
require "qrpc/locator"
require "eventmachine"


EM::run do
    client = QRPC::Client::new QRPC::Locator::new :test
#    puts client.inspect

#    client.something_bad do |i|
#        puts i
#    end

    count = 0

    10000.times do
        client.subtract(2, 3) do |i|
            puts i
            count += 1
            if count >= 10000
                EM::stop
            end
        end
    end
    
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

b.use("qrpc-test-input")
b.watch("qrpc-cc-output")
b.put(req1.to_json)
b.put(req2.to_json)

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
