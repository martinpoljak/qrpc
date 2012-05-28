# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/general"
require "qrpc/protocol/abstract/request"
require "qrpc/protocol/json-rpc/native/qrpc-object"
require "json-rpc-objects/request"

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
                
                attr_writer :native
                @native 

                ##
                # Parses the data for new object.
                #
                # @param [String] raw  raw data
                # @return [Request]  new request according to data
                #
                                
                def self.parse(raw)
                    object = self::new 
                    object.native = JsonRpcObjects::Request::parse(raw, :wd, self::options.serializer)
                    return object
                end
                

                ##
                # Returns the native object.
                # @return [JsonRpcObjects::Response]  native response object
                #
                
                def native
                    if @native.nil?
                        client_id = @options.client_id.to_s
                        qrpc = QRPC::Protocol::JsonRpc::Native::QrpcObject::create(:client => client_id, :priority => @options.priority, :notification => @options.notification)
                        qrpc.serializer = @options.serializer
                        
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
                
                ##
                # Returns ID of the request.
                # @return [Object] request ID
                #
                
                def id
                    self.native.id
                end
                
                ##
                # Returns method identifier of the request.
                # @return [Symbol]
                #
                
                def method
                    @native.method
                end

                ##
                # Returns method params of the request.
                # @return [Array]
                #
                
                def params
                    @native.params
                end

                ##
                # Returns the QRPC request priority.
                # @return [Integer]
                #
                 
                def priority
                    @native.qrpc["priority"]
                end

                ##
                # Returns the QRPC request client identifier.
                # @return [Object]
                #
                 
                def client
                    @native.qrpc["client"]
                end
                
                ##
                # Indicates, job is notification.
                # @return [Boolean]
                #
                
                def notification?
                    @native.qrpc["notification"]
                end
                
            end
        end
    end
end
