# encoding: utf-8
require "json-rpc-objects/serializer/json"  # >= 0.4.1

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
    
    ##
    # Holds default serializer module link.
    # @since 0.4.0
    #
    
    DEFAULT_SERIALIZER = JsonRpcObjects::Serializer::JSON
    
    ##
    # Holds default serializer instance.
    # @since 0.4.0
    #
    
    @@default_serializer = nil
    
    ##
    # Returns default serializer instance.
    #
    # @return [JsonRpcObjects::Serializer] serializer instance
    # @since 0.4.0
    #
    
    def self.default_serializer
        if @@default_serializer.nil?
            @@default_serializer = QRPC::DEFAULT_SERIALIZER::new
        end
        
        return @@default_serializer
    end
    
end
