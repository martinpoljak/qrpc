# encoding: utf-8
require "beanstalk-client"
require "json-rpc-objects/request"

b = Beanstalk::Pool::new(["localhost:11300"])
req1 = JsonRpcObjects::Request::create(:bar, nil, :id => "job1", :qrpc => { :version => "1.0", :client => :cc })
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

=begin
100.times do
    b.put(req1.to_json)
    job = b.reserve
    puts job.body
    job.delete
end
=end
