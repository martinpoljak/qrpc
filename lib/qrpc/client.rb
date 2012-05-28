# encoding: utf-8
# (c) 2011-2012 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/client/dispatcher"
require "qrpc/generator/uuid"
require "qrpc/general"

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
        #
        # @param [QRPC::Locator] locator of the queues
        # @param [QRPC::Generator] ID generator
        # @param [QRPC::Protocol::Abstract] protocol protocol of the session
        #
        
        def initialize(locator, generator = QRPC::default_generator, protocol = QRPC::default_protocol)
            @dispatcher = QRPC::Client::Dispatcher::new(locator, generator, protocol)
        end
                
        ##
        # Handles call to RPC. (*********)
        #
        # Be warn, arguments will be serialized to JSON, so they should
        # be serializable nativelly or implement +#to_s+ or +#to_json+ 
        # method.
        #
        # @param [Symbol] name name of the called methods
        # @param [Array] args arguments of the called methods
        # @param [Proc] block callback for returning 
        #
        
        def method_missing(name, *args, &block)
            @dispatcher.put(@dispatcher.create_job(name, args, &block))
        end
               
    end
end
