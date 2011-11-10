# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/general"
require "qrpc/protocol/abstract/request"
require "qrpc/protocol/json-rpc/native/qrpc-object"

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
                #
                
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
                # Returns the native object.
                # @return [JsonRpcObjects::Response]  native response object
                #
                
                def native
                    if @native.nil?
                        client_id = @options.client_id.to_s
                        qrpc = QRPC::Protocol::JsonRpc::Native::QrpcObject::create(:client => client_id, :priority => @options.priority)
                        
                        @native = JsonRpcObjects::Request::create(@options[:method], @options.arguments, :id => @options.id, :qrpc => qrpc.output)
                        @native.serializer = @options.serializer
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
