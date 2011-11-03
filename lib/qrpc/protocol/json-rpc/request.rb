# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/general"
require "qrpc/protocol/abstract/request"

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
            # JSON-RPC request implementation.
            # @since 0.9.0
            #
            
            class Request < QRPC::Protocol::Abstract::Request
              
                ##
                # Holds native object.
                # @return [JsonRpcObjects::Request]  native request
                #
                
                attr_accessor :native
                @native 

                ##
                # Parses the data for new object.
                #
                # @param [String] raw  raw data
                # @return [Request]  new request according to data
                #
                                
                def self.parse(raw)
                    object = self::new 
                    object.native = JsonRpcObjects::Request::parse(raw, :wd, @options.serializer)
                    return object
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
