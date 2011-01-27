# encoding: utf-8


##
# General QRPC module.
#

module QRPC
    
    ##
    # Resource locator.
    #
    
    class Locator
    
        ##
        # Contains queue name.
        #
        
        @queue
        attr_accessor :queue
        
        ##
        # Contains host.
        #
        
        @host
        attr_accessor :host
        
        ##
        # Contains port.
        #
        
        @port
        attr_accessor :port
        
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
        # @param [String, Symbol] queue queue name
        # @param [String] host host name
        # @param [Integer] port port of the host
        #
        
        def initialize(queue, host = "localhost", port = 11300)
            @queue = queue.to_s
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
            
            queue = match[1]
            host = match[2]
            
            if match.length == 3
                port = match[3]
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
            @queue.dup << "@" << @host << ":" << @port.to_s
        end
        
    end
    
end
