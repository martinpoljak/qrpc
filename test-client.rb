# encoding: utf-8
require "beanstalk-client"
require "json-rpc-objects/request"

b = Beanstalk::Pool::new(["localhost:11300"])
req = JsonRpcObjects::Request::create(:bars, nil, :id => "ii", :qrpc => { :version => "1.0", :client => :cc })

b.use("qrpc-test-input")
b.watch("qrpc-cc-output")
b.put(req.to_json)

job = b.reserve
puts job.body
job.delete
