# encoding: utf-8
# (c) 2012 Martin Kozák (martinkozak@martinkozak.net)

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
        # Object protocol implementation.
        # @since 0.9.0
        #
        
        class Object < Abstract
        end
               
    end
end

require "qrpc/protocol/object/error"
require "qrpc/protocol/object/request"
require "qrpc/protocol/object/response"
