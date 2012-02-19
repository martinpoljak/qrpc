# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

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
    #
    
    module Protocol

        ##
        # Abstract protocol implementation.
        # @since 0.9.0
        #
        
        class Abstract
        
            ##
            # Abstract request implementation.
            #
            # @since 0.9.0
            # @abstract
            #
            
            class Request < Object
              
                ##
                # Constructor.
                #
                # @param [Hash] init  initial options
                # @abstract
                #
                
                def initialize(init = { })
                    super(init)
                    if self.instance_of? Request
                        not_implemented
                    end
                end

                ##
                # Parses the data for new object.
                #
                # @param [String] raw  raw data
                # @return [Request]  new request according to data
                # @abstract
                #
                                
                def self.parse(raw)
                    not_implemented
                end
                
                ##
                # Returns ID of the request.
                # @return [Object] request ID
                #
                
                def id
                    not_implemented
                end
            end
        end
    end
end