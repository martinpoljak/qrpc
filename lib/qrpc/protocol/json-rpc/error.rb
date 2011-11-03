# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/general"
require "qrpc/protocol/abstract/error"
require "qrpc/protocol/json-rpc/native/exception-data"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Protocols helper module.
    # @since 0.9.0
    #
    
    module Protocol

        ##
        # JSON-RPC protocol implementation.
        # @since 0.9.0
        #
        
        class JsonRpc
        
            ##
            # JSON-RPC error implementation.
            # @since 0.9.0
            #
            
            class Error < QRPC::Protocol::Abstract::Error
              
                ##
                # Holds native object.
                #
                
                @native 
                
                ##
                # Returns the native object.
                # @return [JsonRpcObjects::Generic::Error]  native response object
                #
                
                def native
                    if @native.nil?
                        exception = @options.exception
                        request = @options.request
                        data = QRPC::Protocol::JsonRpc::Native::ExceptionData::create(exception)

                        @native = request.class::version.error::create(100, "exception raised during processing the request", :error => data.output)
                    end
                    
                    @native
                end
                
                ##
                # Serializes object to the resultant form.
                # @return [String]  serialized form
                #
                
                def serialize
                    self.native.serialize
                end
                
            end
        end
    end
end
