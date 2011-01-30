# encoding: utf-8
require "uuid"
require "json-rpc-objects/request"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Queue RPC client.
    #
    
    class Client
    
        ##
        # Holds job ID.
        #
        
        @id
        
        ##
        # Holds associated client ID.
        #
        
        @client_id
        
        ##
        # Holds method name of the job.
        #
        
        @job
        
        ##
        # Holds method arguments array.
        #
        
        @arguments
        
        ##
        # Holds job callback.
        #
        
        @callback
        
        ##
        # Message priority.
        #
        
        @priority
    
        ##
        # Queue RPC client job.
        #
        
        class Job
            
            ##
            # Constructor.
            #
            
            def initialize(client_id, method, arguments = [ ], priority = 50, &callback)
                @client_id = client_id
                @method = method_missing
                @arguments = arguments
                @callback = callback
                @priority = priority
            end
            
            ##
            # Returns job ID.
            #
            
            def id
                if @id.nil?
                    @id = UUID.generate
                end
                
                return @id
            end
            
            ##
            # Converts job to JSON.
            #
            
            def to_json
                qrpc = {
                    :version => "1.0",
                    :client => @client_id,
                    :priority => @priority,
                }
                
                req = JsonRpcObjects::Request::create(@method, @arguments, :id => self.id, :qrpc => qrpc)
                return req.to_json
            end
            
        end
                
    end
end
