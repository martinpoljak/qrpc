# encoding: utf-8

##
# General QRPC module.
#

module QRPC

    ##
    # Prefix for handled queues.
    # @since 0.1.1
    #
    
    QUEUE_PREFIX = "qrpc"
    
    ##
    # Input queue postfix.
    # @since 0.1.1
    #
    
    QUEUE_POSTFIX_INPUT = "input"
    
    ##
    # Output queue postfix.
    # @since 0.1.1
    #
    
    QUEUE_POSTFIX_OUTPUT = "output"
    
    ##
    # Indicates default job priority.
    # @since 0.2.0
    #
    
    DEFAULT_PRIORITY = 50

end
