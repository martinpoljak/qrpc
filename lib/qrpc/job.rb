# encoding: utf-8

require "eventmachine"
require "json-rpc-objects/request"

module QRPC
    class Server

        ##
        # Queue RPC job.
        #
        
        class Job
            include EM::Deferrable
            
            ##
            # Holds beanstalk job.
            #
            
            @job
            
            ##
            # Holds API object.
            #
            
            @api
            
            ##
            # Constructor.
            #
            # @param [Object] object which will serve as API
            # @param [EM::Beanstalk::Job] job beanstalk job
            #
            
            def initialize(api, job)
                @api = api
                @job = job
            end
            
            ##
            # Starts processing.
            #
            
            def process!
                request = JsonRpcObjects::Request::parse(@job.body)
                result = @api.send(request.method, *request.params)
                response = request.class::version.response::create(result, nil, :id => request.id)
                
                response.qrpc = { "version" => "1.0" }
                result = {
                    :output => response.to_json,
                    :client => request.qrpc["client"]
                }

                @job.delete()
                self.set_deferred_status :succeeded, result
            end
            
        end
    end
end
