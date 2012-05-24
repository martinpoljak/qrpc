# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/protocol/exception-data"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Queue RPC client.
    #
    # @note Since 0.3.0, all non-system methods was moved to the 
    #   {Dispatcher} module for maximal avoiding the user API 
    #   name conflicts.
    # @since 0.2.0
    #
    
    class Client
    
        ##
        # Queue RPC client exception.
        # @since 0.2.0
        #
        
        class Exception < ::Exception
            
            ##
            # Constructor.
            # Initializes from protocol exception data object.
            #
            # @param [String] name  a exception name
            # @param [String] message  a exception message
            # @param [Array] backtrace  the backtrace array
            #
            
            def initialize(name, message, backtrace = [ ])
                message = name + ": " + message
                super(message)
                
                self.set_backtrace(backtrace)
            end
            
        end
    end
end
