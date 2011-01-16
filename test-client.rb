# encoding: utf-8
require "beanstalk-client"
require "json-rpc-objects/request"

b = Beanstalk::Pool::new(["localhost:11300"])
req1 = JsonRpcObjects::Request::create(:bar, nil, :id => "job1", :qrpc => { :version => "1.0", :client => :cc })
req2 = JsonRpcObjects::Request::create(:something_bad, nil, :id => "job2", :qrpc => { :version => "1.0", :client => :cc })

b.use("qrpc-test-input")
b.watch("qrpc-cc-output")
b.put(req1.to_json)
b.put(req1.to_json)

2.times do
    job = b.reserve
    puts job.body
    job.delete
end
