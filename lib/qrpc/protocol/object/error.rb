# encoding: utf-8
# (c) 2012 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/general"
require "qrpc/protocol/abstract/error"

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
        
        class Object
        
            ##
            # Object error implementation.
            # @since 0.9.0
            #
            
            class Error < QRPC::Protocol::Abstract::Error
                
                ##
                # Serializes object to the resultant form.
                # @return [Error]  serialized form
                #
                
                def serialize
                    self
                end
                
            end
        end
    end
end
