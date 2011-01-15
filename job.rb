# encoding: utf-8

require "eventmachine"
require "json-rpc-objects/request"

module MNF
    module RPC
        module Queue
            
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
                    
                    result = {
                        :output = response.to_json,
                        :client = request.client
                    }
                    
                    @job.delete()
                    self.set_deferred_status :suceeded, result
                end
                
            end
        end
    end
end
