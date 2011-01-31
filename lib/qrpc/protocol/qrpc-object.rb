# encoding: utf-8
require "json-rpc-objects/generic"
require "json-rpc-objects/request"

##
# General QRPC module.
#

module QRPC
    
    ##
    # JSON RPC helper module.
    # @since 0.2.0
    #

    module Protocol

        ##
        # QRPC JSON-RPC QRPC object. Extends the 
        # +JsonRpcObjects::Generic::Object+. See its documentation for
        # additional methods.
        #
        # @since 0.2.0
        #
        
        class QrpcObject < JsonRpcObjects::Generic::Object
        
            ##
            # Holds JSON-RPC version indication.
            #
            
            VERSION = JsonRpcObjects::Request::VERSION
            
            ##
            # Creates new QRPC JSON-RPC object.
            #
            
            def self.create(opts = { })
                self::new(opts)
            end
            
            ##
            # Checks correctness of the object data.
            #
            
            def check!
                if (not @priority.nil?) and not (@priority.kind_of? Numeric)
                    raise Exception::new("Priority is expected to be Numeric.")
                end
            end
                        
            ##
            # Renders data to output form.
            # @return [Hash] with data of object
            #

            def output
                result = { :version => "1.0" }
                
                if not @priority.nil?
                    result[:priority] = @priority
                end
                
                if not @client_id.nil?
                    result[:client_id] = @client_id
                end
                
                return result
            end
       

            protected
            
            ##
            # Assigns data.
            #

            def data=(value, mode = nil)
                data = __convert_data(value, mode)
                
                @priority = data[:priority]
                @client_id = data[:client_id]
            end

            ##
            # Converts data to standard (defined) format.
            #
            
            def normalize!
                if not @priority.nil?
                    @priority = @priority.to_i
                end
            end
            
        end
                
    end
end
