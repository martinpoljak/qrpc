# encoding: utf-8
require "uuid"
require "qrpc/protocol/request"
require "qrpc/client/exception"
require "qrpc/general"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Queue RPC client.
    #
    
    class Client
    
        ##
        # Queue RPC client job.
        # @since 0.2.0
        #
        
        class Job

            ##
            # Holds job ID.
            #
            
            @id
            
            ##
            # Holds associated client ID.
            #
            
            @client_id
            
            ##
            # Holds method name of the job.
            #
            
            @job
            
            ##
            # Holds method arguments array.
            #
            
            @arguments
            
            ##
            # Holds job callback.
            #
            
            @callback
            
            ##
            # Message priority.
            #
            
            @priority
            
            ##
            # Job result.
            #
            
            @result
        
            ##
            # Constructor.
            #
            
            def initialize(client_id, method, arguments = [ ], priority = QRPC::DEFAULT_PRIORITY, &callback)
                @client_id = client_id
                @method = method
                @arguments = arguments
                @callback = callback
                @priority = priority
            end
            
            ##
            # Returns job ID.
            #
            
            def id
                if @id.nil?
                    @id = UUID.generate.to_sym
                end
                
                return @id
            end
            
            ##
            # Converts job to JSON.
            #
            
            def to_json
                QRPC::Protocol::Request::create(@client_id, @id, @method, @arguments, @priority).to_json
            end
            
            ##
            # Indicates message is notification. So callback isn't set
            # and it doesn't expect any result.
            #
            
            def notification?
                @callback.nil?
            end
            
            ##
            # Assigns job result and subsequently calls callback.
            #
            
            def assign_result(result)
                if not result.error?
                    @result = result.result
                else
=begin
                    STDERR.write(">>> Exception while call ID: " << self.id.to_s << "\n")
=end                    
                    exception = QRPC::Client::Exception::get(result.error)
=begin
                    STDERR.write exception.class.name.dup << ": " << exception.message << "\n"
                    
                    exception.backtrace.each do |i|
                        STDERR.write "	from " << i << "\n"
                    end
=end                    
                    raise exception
                end
                
                if not @callback.nil?
                    @callback.call(@result)
                end
            end
            
        end
                
    end
end
