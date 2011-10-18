# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

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
    # @note Since 0.3.0, all non-system methods was moved to the 
    #   {Dispatcher} module for maximal avoiding the user API 
    #   name conflicts.
    # @since 0.2.0
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
            # Data serializer.
            # @since 0.4.0
            #
            
            @serializer

            ##
            # ID generator.
            # @since 0.9.0
            #
            
            @generator
                        
            ##
            # Job result.
            #
            
            @result
        
            ##
            # Constructor.
            #
            # @param [Symbol] client_id  client (session) ID
            # @param [Symbol] method  job method name
            # @param [Array] arguments  array of arguments for job
            # @param [Integer] priority  job priority
            # @param [QRPC::Generator] ID generator
            # @param [JsonRpcObjects::Serializer] serializer  data serializer
            # @param [Proc] callback  result callback
            #
            
            def initialize(client_id, method, arguments = [ ], priority = QRPC::DEFAULT_PRIORITY, generator = QRPC::default_generator, serializer = QRPC::default_serializer, &callback)
                @client_id = client_id
                @method = method
                @arguments = arguments
                @callback = callback
                @priority = priority
                @serializer = serializer
                @generator = generator
            end
            
            ##
            # Returns job ID.
            # @return [Symbol] job ID
            #
            
            def id
                if @id.nil?
                    @id = @generator.generate(self)
                else
                    @id
                end
            end
            
            ##
            # Converts job to JSON.
            #
            # @return [String] job in JSON form (JSON-RPC)
            # @deprecated Sice 0.4.0. Use +#serialize+.
            # @see #serialize
            #
            
            def to_json
                QRPC::Protocol::Request::create(@client_id, @id, @method, @arguments, @priority).to_json
            end

            ##
            # Serializes job using serializer.
            #
            # @return [Object] serialized object
            # @since 0.4.0
            #
            
            def serialize
                QRPC::Protocol::Request::create(@client_id, @id, @method, @arguments, @priority, @serializer).serialize
            end
             
            ##
            # Indicates message is notification. So callback isn't set
            # and it doesn't expect any result.
            #
            # @return [Boolean] +true+ if it's, +false+ in otherwise
            #
            
            def notification?
                @callback.nil?
            end
            
            ##
            # Assigns job result and subsequently calls callback.
            # @param [JsonRpcObjects::Generic::Response] result of the call
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
