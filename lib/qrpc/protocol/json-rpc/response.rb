# encoding: utf-8
# (c) 2011-2012 Martin Kozák (martinkozak@martinkozak.net)

require "base64"

require "qrpc/general"
require "qrpc/protocol/abstract/response"
require "qrpc/protocol/json-rpc/native/qrpc-object"
require "json-rpc-objects/response"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Protocols helper module.
    # @since 0.9.0
    #
    
    module Protocol

        ##
        # JSON-RPC protocol implementation.
        # @since 0.9.0
        #
        
        class JsonRpc
        
            ##
            # JSON-RPC response implementation.
            # @since 0.9.0
            #
            
            class Response < QRPC::Protocol::Abstract::Response
              
                ##
                # Holds native object.
                #
                
                attr_writer :native
                @native 

                ##
                # Parses the data for new object.
                #
                # @param [String] raw  raw data
                # @return [Response]  new request according to data
                #
                                
                def self.parse(raw)
                    object = self::new
                    object.native = JsonRpcObjects::Response::parse(raw, :wd, self::options.serializer)
                    return object
                end
                
                ##
                # Returns the native object.
                # @return [JsonRpcObjects::Response]  native response object
                #
                
                def native
                    if @native.nil?
                        result = @options.result
                        error = @options.error
                        request = @options.request
                        
                        error_native = error.nil? ? nil : error.native
                        @native = request.native.class::version.response::create(result, error_native, :id => request.id)
                        @native.serializer = @options.serializer
                        @native.qrpc = QRPC::Protocol::JsonRpc::Native::QrpcObject::create.output
                    end
                    
                    @native
                end
                
                ##
                # Serializes object to the resultant form.
                # @return [String]  serialized form
                #
                
                def serialize
                    self.native.serialize
                end
                
                ##
                # Returns ID of the response.
                # @return [Object] response ID
                #
                
                def id
                    self.native.id
                end
                
                ##
                # Indicates, error state of the response.
                # @return [Boolean] error indication
                #
                
                def error?
                    self.native.error?
                end
                                  
                ##
                # Returns response error.
                # @return [Exception] error object
                #
                
                def error
            
                    # Converts protocol exception to exception data object
                    proto = QRPC::Protocol::JsonRpc::Native::ExceptionData::new(native.error.data)
                
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
                        backtrace = data.backtrace.map { |i| Base64.decode64(i) }
                        backtrace.reject! { |i| i.empty? }
                        exception = self::new(data.name, data.message, backtrace)
                    end
    
                    return exception
                    
                end
                
                ##
                # Returns response result.
                # @return [Object] response result
                #
                
                def result
                    self.native.result
                end
                             
            end
        end
    end
end
