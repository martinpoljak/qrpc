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
        # QRPC JSON-RPC request.
        # @since 0.2.0
        #
        
        class Request < JsonRpcObjects::Request
            
            ##
            # Creates new QRPC request.
            #
            
            def self.create(client_id, id, method, arguments = [ ], priority = QRPC::DEFAULT_PRIORITY)
                qrpc = QRPC::Protocol::QrpcObject::create(:client => client_id, :priority => priority)
                super(method, arguments, :id => id, :qrpc => qrpc)
            end
        end
                
    end
end
