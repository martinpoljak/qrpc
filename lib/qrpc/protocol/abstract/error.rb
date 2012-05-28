# encoding: utf-8
# (c) 2011-2012 Martin Kozák (martinkozak@martinkozak.net)

require "abstract"
require "qrpc/general"
require "qrpc/protocol/abstract/object"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Protocols helper module.
    # @since 0.9.0
    #-
    
    module Protocol

        ##
        # Abstract protocol implementation.
        # @since 0.9.0
        #
        
        class Abstract
        
            ##
            # Abstract error object implementation.
            #
            # @since 0.9.0
            # @abstract
            #
            
            class Error < Object
              
                ##
                # Constructor.
                #
                # @param [Hash] init  initial options
                # @abstract
                #
                
                def initialize(init = { })
                    super(init)
                    if self.instance_of? Error
                        not_implemented
                    end
                end
 
            end
        end
    end
end