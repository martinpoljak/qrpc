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
                #
                # @return [Object] request ID
                # @abstract
                #
                
                def id
                    not_implemented
                end
                
                ##
                # Returns method identifier of the request.
                #
                # @return Symbol
                # @abstract
                #
                
                def method
                    not_implemented
                end

                ##
                # Returns method params of the request.
                #
                # @return Array
                # @abstract
                #
                
                def params
                    not_implemented
                end

                ##
                # Returns the QRPC request priority.
                # @return Integer
                #
                 
                def priority
                    not_implemented
                end

                ##
                # Returns the QRPC request client identifier.
                # @return Object
                #
                 
                def client
                    not_implemented
                end
                
                ##
                # Indicates, job is notification.
                # @return Boolean
                #
                
                def notification?
                    not_implemented
                end
                
            end
        end
    end
end