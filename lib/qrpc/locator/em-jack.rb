# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "hash-utils/array"
require "unified-queues"
require "em-jack"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Resource locators.
    #
    
    module Locator
      
        ##
        # Locator for 'em-jack' (so EventMachine Beanstalk implementation) 
        # queue type.
        #
        # @see https://github.com/dj2/em-jack
        # @since 0.9.0
        # 
        
        class EMJackLocator

            ##
            # Holds the queue interface.
            # @return [UnifiedQueues::Multi] input queue
            #
            
            @queue
            
            ##
            # Contains queue name.
            # @return [String]
            #
    
            attr_accessor :queue_name
            @queue_name
            
            ##
            # Contains host.
            # @return [String]
            #
    
            attr_accessor :host
            @host
            
            ##
            # Contains port.
            # @return [Integer]
            #
    
            attr_accessor :port
            @port
            
            ##
            # Parser.
            #
            
            PARSER = /^(.+)@(.+)(?:\:(\d+))?$/
            
            ##
            # Default port.
            #
            
            DEFAULT_PORT = 11300
            
            ##
            # Constructor.
            #
            # @param [String, Symbol] queue_name queue name
            # @param [String] host host name
            # @param [Integer] port port of the host
            #
            
            def initialize(queue_name, host = "localhost", port = 11300)
                @queue_name = queue_name.to_s
                @host = host
                @port = port
            end
            
            ##
            # Parses the locator.
            # Excpects form +<queue>@<host>:<port>+. Port is optional.
            #
            # @param [String] string locator in string form
            # @return [QRPC::Locator] new instance
            #
            
            def self.parse(string)
                match = string.match(self::PARSER)
                
                queue = match.first
                host = match.second
                
                if match.length == 3
                    port = match.third
                else
                    port = self::DEFAULT_PORT
                end
                
                port = port.to_i
                
                ##
                
                return self::new(queue, host, port);
            end
            
            ##
            # Converts back to string.
            # @return [String] locator in string form
            #
            
            def to_s
                @queue_name.dup << "@" << @host << ":" << @port.to_s
            end
            
            ##
            # Returns universal queue interface.
            # @return [UnifiedQueues::Multi] queue
            #
            
            def queue
                if @queue.nil?
                    @queue = UnifiedQueues::Multi::new EMJack::Connection, :host => @host, :port => @port
                else
                    @queue
                end
            end
            
            alias :input_queue :queue
            alias :output_queue :queue
                
        end
        
    end
    
end
