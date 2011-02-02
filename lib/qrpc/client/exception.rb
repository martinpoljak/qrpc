# encoding: utf-8

##
# General QRPC module.
#

module QRPC
    
    ##
    # Queue RPC client.
    #
    
    class Client
    
        ##
        # Queue RPC client exception.
        # @since 0.2.0
        #
        
        class Exception < ::Exception

            ##
            # Gets one from protocol exception object.
            # Returns marshalled original or reconstructed version.
            #
            # @param [JsonRpcObjects::Generic::Error] proto JSON-RPC error object
            # @return [Exception, QRPC::Client::Exception] exception according
            #   to sucessfullness of the unmarshaling
            #
            
            def self.get(proto)
            
                # Converts protocol exception to exception data object
                proto = QRPC::Protocol::ExceptionData::new(proto.data)
            
                # Tries to unmarshall
                if proto.dump.format == :ruby
                    begin
                        exception = Marshal.load(Base64.decode64(proto.dump.raw))
                    rescue
                        # pass
                    end
                end
                
                # If unsuccessfull, creates from data
                if exception.nil?
                    exception = self::new(proto)
                end

                return exception
            end
            
            ##
            # Constructor.
            # Initializes from protocol exception data object.
            #
            # @param [QRPC::Protocol::ExceptionData] data exception data object
            #
            
            def initialize(data)
                message = data.name.dup << ": " << data.message
                backtrace = data.backtrace.map { |i| Base64.decode64(i) }
                backtrace.reject! { |i| i.empty? }
                
                super(message)
                self.set_backtrace(backtrace)
            end
            
        end
    end
end
