# encoding: utf-8
# (c) 2011-2012 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/generator/uuid"

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
    # Holds default generator module link.
    # @since 0.9.0
    #
    
    DEFAULT_GENERATOR = QRPC::Generator::UUID
    
    ##
    # Holds default protocol instance.
    # @since 0.4.0
    #
    
    @@default_protocol = nil
    
    ##
    # Holds default generator instance.
    # @since 0.9.0
    #
    
    @@default_generator = nil
    
    ##
    # Returns default protocol instance.
    #
    # @return [QRPC::Protocol::Abstract] protocol instance
    # @since 0.9.0
    #
    
    def self.default_protocol
        if @@default_protocol.nil?
            begin
                @@default_protocol = QRPC::Protocol::JsonRpc::new(:serializer => JsonRpcObjects::Serializer::JSON::new)
            rescue NameError
                require "json-rpc-objects/serializer/json"  # >= 0.4.1
                require "qrpc/protocol/json-rpc"
                retry
            end
        else
            @@default_protocol
        end
    end
    
    ##
    # Returns default generator instance.
    #
    # @return [QRPC::Generator::UUID] generator instance
    # @since 0.9.0
    #
    
    def self.default_generator
        if @@default_generator.nil?
            @@default_generator = QRPC::DEFAULT_GENERATOR::new
        else
            @@default_generator
        end
    end
            
end
