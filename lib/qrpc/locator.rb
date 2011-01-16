# encoding: utf-8

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
        
        def initialize(queue, host = "localhost", port = 11300)
            @queue = queue
            @host = host
            @port = port
        end
        
        ##
        # Parses the locator.
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
        #
        
        def to_s
            @queue.dup << "@" << @host << ":" << @port.to_s
        end
        
    end
    
end
