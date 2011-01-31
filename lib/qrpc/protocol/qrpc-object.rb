# encoding: utf-8

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
        # QRPC JSON-RPC QRPC object.
        # @since 0.2.0
        #
        
        class QrpcObject
        
            ##
            # Holds QRPC object options.
            #
            
            @data
            
            ##
            # Creates new QRPC JSON-RPC object.
            #
            
            def self.create(opts = { })
                self::new(opts)
            end
            
            ##
            # Constructor.
            #
            
            def initialize(data)
            end
            
            ##
            # Converts to JSON.
            #
            
            def to_json
                return result
            end
                
            ##
            # Returns version identifier.
            #
            
            def version
                :"1.0"
            end
        end
                
    end
end
