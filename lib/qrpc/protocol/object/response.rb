# encoding: utf-8
# (c) 2012 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/general"
require "qrpc/protocol/abstract/response"

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
            # Object response implementation.
            # @since 0.9.0
            #
            
            class Response < QRPC::Protocol::Abstract::Response

                ##
                # Parses the data for new object.
                #
                # @param [String] raw  raw data
                # @return [Response]  new request according to data
                #
                                
                def self.parse(raw)
                    self::new(raw.options)
                end

                ##
                # Serializes object to the resultant form.
                # @return [Response]  serialized form
                #
                
                def serialize
                    self
                end
                
                ##
                # Returns ID of the response.
                # @return [Object] response ID
                #
                
                def id
                    @options.request.id
                end
                
                ##
                # Indicates, error state of the response.
                # @return [Boolean] error indication
                #
                
                def error?
                    not self.error.nil?
                end
                                  
                ##
                # Returns response error.
                # @return [Exception] error object
                #
                
                def error
                    @options.error
                end
                
                ##
                # Returns response result.
                # @return [Object] response result
                #
                
                def result
                    @options.result
                end
                             
            end
        end
    end
end
