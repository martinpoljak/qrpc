# encoding: utf-8
# (c) 2011-2012 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/protocol/abstract"

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
        
        class JsonRpc < Abstract
        end
               
    end
end

require "qrpc/protocol/json-rpc/error"
require "qrpc/protocol/json-rpc/request"
require "qrpc/protocol/json-rpc/response"
