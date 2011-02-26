# encoding: utf-8
require "qrpc/client/dispatcher"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Queue RPC client.
    #
    # @note Since 0.3.0, all non-system methods was moved to 
    #   {Dispatcher} module for maximal avoiding the user API 
    #   name conflicts.
    # @since 0.2.0
    #
    
    class Client
    
        ##
        # Holds working dispatcher.
        #
        # @return [Dispatcher] 
        # @since 0.3.0
        #
        
        attr_accessor :dispatcher
        @dispatcher
        
        ##
        # Constructor.
        # @param [QRPC::Locator] locator of the output queue
        #
        
        def initialize(locator)
            @dispatcher = QRPC::Client::Dispatcher::new(locator)
        end
                
        ##
        # Handles call to RPC. (*********)
        #
        # Be warn, arguments will be serialized to JSON, so they should
        # be serializable nativelly or implement +#to_json+ method.
        #
        # @param [Symbol] name name of the called methods
        # @param [Array] args arguments of the called methods
        # @param [Proc] block callback for returning result
        #
        
        def method_missing(name, *args, &block)
            @dispatcher.put(@dispatcher.create_job(name, args, &block))
        end
               
    end
end
