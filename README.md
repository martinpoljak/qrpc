QRPC
====

**QRPC** currently implements queued JSON-RPC both client and server 
which works as normal RPC server, but through queue interface, so allows 
highly scalable, distributed and asynchronous remote API implementation 
and fast data processing. 

It's based on [eventmachine][1] and [beanstalkd][2] so it's fast and 
thread safe. 

### Protocol

It utilizes [JSON-RPC][3] protocol in versions both [1.1][4] and [2.0][5].
Adds special data member `qrpc` with few options appropriate for queue 
processing. Typicall request looks in Ruby hash notation like:
    
    {
        "jsonrpc" => "2.0",
        "method" => "subtract",
        "params" => [2, 1],
        "id" => <some unique job id>,
        "qrpc" => {
            "version" => "1.0",
            "client" => <some unique client id>,
            "priority" => 30
        }
    }
    
The last `priority` member is optional, others are expected to be 
present including them which are optional in classic JSON-RPC. 
Default priority is 50.

Typical response looks like:

    {
        "jsonrpc" => "2.0",
        "result" => 1,
        "id" => <some unique job id>,
        "qrpc" => {
            "version" => "1.0",
        }
    }
    
And in case of exception:

    {
        "jsonrpc" => "2.0",
        "error" => {
            "code" => <some code>,
            "message" => <some message>,
            "data" => {
                "name" => <exception class name>,
                "message" => <exception message>,
                "backtrace" => <array of Base64 encoded strings>,
                "dump" => {
                    "raw" => <Base 54 encoded marshaled exception object>,
                    "format" => "ruby"
                }
            }
        },
        
        "id" => <some unique job id>,
        "qrpc" => {
            "version" => "1.0",
        }
    }
    
Both `backtrace` and `dump` members are optional.

    
### Server Usage

Usage is simple. Look example:

    require "qrpc/server"
    require "qrpc/locator"
    
    class Foo
        def subtract(x, y)
            x - y
        end
    end

    server = QRPC::Server::new Foo::new
    server.listen! QRPC::Locator::new "test"
    
This creates an instance of `Foo` which will serve as API, creates
locator of the queue *test* at default server *localhost:11300*. Queue 
name will be remapped to the real name *qrpc-test-input*. After call to 
`#listen!`, it will run eventmachine and start listening for calls. If 
you want to run it inside already run eventmachine, simply call 
`#start_listening` with the same parameters.

Calls processing is thread safe because of eventmachine concept 
similar to fibers. Default number at one time processed jobs is 20,
but it can be changed by setting `:max_jobs => <number>` to `#listen!` 
or `#start_listening`.

The `#precall` and `#postcall` handlers are supported on the API class
called if API responds to them. Currently, they don't receive any
parameters and are intended for simple call initialization only.

Reponse will be put to the same queue server, to queue named 
`qrpc-<client identifier>-output`, with structure described above. 

### Client Usage

Client usage is simple too. Look example:

    require "eventmachine"
    require "qrpc/client"
    require "qrpc/locator"
    
    EM::run do
        client = QRPC::Client::new QRPC::Locator::new "test"
        client.subtract(2, 3) { |result| puts result }  # prints out -1
    end
    
This connects to the *test* queue at default server *localhost:11300*,
puts request to the real queue name *qrpc-test-input* and waits and then
prints the result from `qrpc-<client-id>-output` queue. In case of 
multiple requests should be noted, results can arrive in any order 
because, of sure, QRPC is pseudo-fibered and asynchronous from 
its principle.
    
Client is implemented as [evented][1] too, but in case of need you can 
implement another one with non-evented interface using whatever 
[beanstalkd][2] client you like of sure.

Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b 20101220-my-change`).
3. Commit your changes (`git commit -am "Added something"`).
4. Push to the branch (`git push origin 20101220-my-change`).
5. Create an [Issue][6] with a link to your branch.
6. Enjoy a refreshing Diet Coke and wait.


Copyright
---------

Copyright &copy; 2011 [Martin Kozák][7]. See `LICENSE.txt` for
further details.

[1]: http://rubyeventmachine.com/
[2]: http://kr.github.com/beanstalkd/
[3]: http://en.wikipedia.org/wiki/JSON-RPC
[4]: http://groups.google.com/group/json-rpc/web/json-rpc-1-1-alt
[5]: http://groups.google.com/group/json-rpc/web/json-rpc-2-0
[6]: http://github.com/martinkozak/qrpc/issues
[7]: http://www.martinkozak.net/
