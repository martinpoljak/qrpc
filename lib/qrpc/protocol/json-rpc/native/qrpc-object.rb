# encoding: utf-8   
# (c) 2011-2012 Martin Kozák (martinkozak@martinkozak.net)

require "json-rpc-objects/generic/object"
require "json-rpc-objects/request"
require "qrpc/protocol/json-rpc"
require "qrpc/general"
require "hash-utils"

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
        # JSON-RPC protocol implementation.
        # @since 0.9.0
        #
        
        class JsonRpc

            ##
            # Native JSON-RPC classes.
            # @since 0.9.0
            #
            
            module Native
              
                ##
                # QRPC JSON-RPC QRPC object. Extends the 
                # +JsonRpcObjects::Generic::Object+. See its documentation for
                # additional methods.
                #
                # @since 0.2.0
                #
                
                class QrpcObject < JsonRpcObjects::Generic::Object
                
                    ##
                    # Holds JSON-RPC version indication.
                    #
                    
                    VERSION = JsonRpcObjects::Request::VERSION
                    
                    ##
                    # Creates new QRPC JSON-RPC object.
                    #
                    # @param [Hash] QRPC object optional arguments
                    # @return [QRPC::Protocol::QrpcObject] new instance
                    #
                    
                    def self.create(opts = { })
                        self::new(opts)
                    end
                    
                    ##
                    # Checks correctness of the object data.
                    #
                    
                    def check!
                        self.normalize!
                        
                        if (not @priority.nil?) and not (@priority.kind_of? Numeric)
                            raise Exception::new("Priority is expected to be Numeric.")
                        end
                        
                        if not (@notification.boolean?)
                            raise Exception::new("Notification is expected to be Boolean.")
                        end
                    end
                                
                    ##
                    # Renders data to output form.
                    # @return [Hash] with data of object
                    #
        
                    def output
                        result = { 
                            "version" => "1.0.2"
                        }
                        
                        if not @priority.nil?
                            result["priority"] = @priority
                        end
                        
                        if not @client.nil?
                            result["client"] = @client.to_s
                        end
                        
                        if @notification.true?
                            result["notification"] = @notification
                        end
                        
                        return result
                    end
               
        
                    protected
                    
                    ##
                    # Assigns data.
                    #
        
                    def data=(value, mode = nil)
                        data = __convert_data(value, mode)
                        
                        @priority = data[:priority]
                        @client = data[:client]
                        @notification = data[:notification]
                    end
        
                    ##
                    # Converts data to standard (defined) format.
                    #
                    
                    def normalize!
                        if not @priority.nil?
                            @priority = @priority.to_i
                        end
                        
                        if @notification.nil?
                            @notification = false
                        end
                    end
                end
            end
        end                
    end
end
