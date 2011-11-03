# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "json-rpc-objects/response"
require "qrpc/general"
require "qrpc/response"
require "qrpc/protocol/abstract/response"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Abstract protocol class.
    #
    # @abstract
    # @since 0.9.0
    #
    
    class Protocol
      
        ##
        # JSON-RPC QRPC provider.
        # @since 0.9.0
        #
        
        class JsonRpc < Protocol

            ##
            # QRPC JSON-RPC response. Extends +JsonRpcObjects::Response+.
            # See its documentation for additional reference.
            #
            # @since 0.9.0
            #
            
            class Response < JsonRpcObjects::Response
            end
            
        end
    end
end
