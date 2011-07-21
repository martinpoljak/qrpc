# encoding: utf-8
require "json-rpc-objects/request"
require "qrpc/general"
require "qrpc/protocol/qrpc-object"

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
        # QRPC JSON-RPC request. Extends +JsonRpcObjects::Request+.
        # See its documentation for additional reference.
        #
        # @since 0.2.0
        #
        
        class Request < JsonRpcObjects::Request
            
            ##
            # Creates new QRPC request.
            #
            # @param [Symbol] client_id  client (session) ID
            # @param [Symbol] method  job method name
            # @param [Array] arguments  array of arguments for job
            # @param [Integer] priority  job priority
            # @param [Proc] callback  result callback
            # @return [QRPC::Protocol::Request] new protocol request object
            #
            
            def self.create(client_id, id, method, arguments = [ ], priority = QRPC::DEFAULT_PRIORITY, serializer = QRPC::DEFAULT_SERIALIZER)
                qrpc = QRPC::Protocol::QrpcObject::create(:client => client_id, :priority => priority)
                obj = super(method, arguments, :id => id, :qrpc => qrpc)
                obj.serializer = serializer
                return obj
            end
        end
                
    end
end
