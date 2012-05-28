# encoding: utf-8
# (c) 2011-2012 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/general"
require "qrpc/protocol/abstract/request"

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
            # Object request implementation.
            # @since 0.9.0
            #
            
            class Request < QRPC::Protocol::Abstract::Request

                ##
                # Parses the data for new object.
                #
                # @param [String] raw  raw data
                # @return [Request]  new request according to data
                #
                                
                def self.parse(raw)
                    self::new(raw.options)
                end
                                
                ##
                # Serializes object to the resultant form.
                # @return [Request]  serialized form
                #
                
                def serialize
                    self
                end
                
                ##
                # Returns ID of the request.
                # @return [Object] request ID
                #
                
                def id
                    @options.id
                end
                
                ##
                # Returns method identifier of the request.
                # @return [Symbol]
                #
                
                def method
                    @options[:method]
                end

                ##
                # Returns method params of the request.
                # @return [Array]
                #
                
                def params
                    @options.arguments
                end

                ##
                # Returns the QRPC request priority.
                # @return [Integer]
                #
                 
                def priority
                    @options.priority
                end

                ##
                # Returns the QRPC request client identifier.
                # @return [Object]
                #
                 
                def client
                    @options.client_id.to_s
                end
                
                ##
                # Indicates, job is notification.
                # @return [Boolean]
                #
                
                def notification?
                    @options.notification
                end
                
            end
        end
    end
end
