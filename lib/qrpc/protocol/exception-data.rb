# encoding: utf-8
require "json-rpc-objects/generic/object"
require "qrpc/protocol/qrpc-object"
require "base64"

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
        # Exception data QRPC JSON-RPC object.
        # @since 0.2.0
        #
        
        class ExceptionData < JsonRpcObjects::Generic::Object
        
            ##
            # Holds JSON-RPC version indication.
            #
            
            VERSION = QRPC::Protocol::QrpcObject::VERSION
            
            ##
            # Holds exception name.
            #
            
            @name
            attr_accessor :name
            
            ##
            # Holds exception message.
            #
            
            @message
            attr_accessor :message
            
            ##
            # Holds backtrace.
            #
            
            @backtrace
            attr_accessor :backtrace
            
            ##
            # Holds native dump.
            #
            
            @dump
            attr_accessor :dump
            
            ##
            # Indicates, data are encoded and should be decoded.
            #
            
            @__encoded
            
            ##
            # Creates new QRPC JSON-RPC object.
            #
            
            def self.create(arg1, message = nil, opts = { })
                if arg1.kind_of? Exception
                    mode = :decoded
                    data = {
                        :name => arg1.class.name,
                        :message => arg1.message,
                        :backtrace => arg1.backtrace,
                        :dump => {
                            "format" => "ruby",
                            "object" => arg1
                        }
                    }
                else
                    mode = :encoded
                    data = {
                        :name => arg1,
                        :message => message
                    }
                end
                
                data.merge! opts
                return self::new(data, mode)
            end
            
            ##
            # Constructor.
            # @param [Hash] data for initializing the object
            #
            
            def initialize(data, mode = :encoded)
                @__encoded = (mode == :encoded)
                super(data)
            end
            
            ##
            # Checks correctness of the object data.
            #
            
            def check!
                self.normalize!

                if not @name.kind_of? Symbol
                    raise Exception::new("Exception name is expected to be Symbol or convertable to symbol.")
                end
                
                if not @backtrace.nil? and not @backtrace.kind_of? Array
                    raise Exception::new("Backtrace is expected to be an Array.")
                end
                
                if not @dump.nil? 
                    if @dump.object.nil? and @dump.raw.nil?
                        raise Exception::new("Either object or RAW form of the dump must be set if dump is set.")
                    elsif @dump.format.nil? or not @dump.format.kind_of? Symbol
                        raise Exception::new("Dump format must be set and must be Symbol.")
                    end
                end
            end
                        
            ##
            # Renders data to output form.
            # @return [Hash] with data of object
            #

            def output
                result = { 
                    :name => @name.to_s,
                    :message => @message,
                }
                
                # Backtrace
                if @backtrace.kind_of? Array
                    result[:backtrace] = @backtrace.map { |i| Base64.encode64(i) }
                end
                   
                # Dump
                if not @dump.nil?
                    result[:dump] = {
                        :format => @dump.format,
                    }
                    
                    if not dump.object.nil?
                        raw = Base64.encode64(Marshal.dump(dump.object))
                    else
                        raw = dump.raw
                    end
                    
                    result[:dump][:raw] = raw
                end
                
                return result
            end
       

            protected
            
            ##
            # Assigns data.
            #

            def data=(value, mode = nil)
                data = __convert_data(value, mode)
                
                # Required
                @name = data[:name]
                @message = data[:message]
                
                # Backtrace
                backtrace = data[:backtrace]
                
                if @__encoded and (backtrace.kind_of? Array)
                    @backtrace = backtrace.map { |i| Base64.decode64(i) }
                end
                
                # Dump
                dump = data[:dump]
                   
                if dump.kind_of? Hash
                    @dump = Struct::new(:format, :raw, :object)::new(dump["format"].downcase.to_sym, dump["raw"], dump["object"])
                    
                    if not @dump.raw.nil? and @dump.object.nil? and (@dump.format == :ruby)
                        @dump.object = Marshal.load(Base64.decode64(@dump.raw))
                    end
                end
                
            end

            ##
            # Converts data to standard (defined) format.
            #
            
            def normalize!
                @name = @name.to_sym
                
                if not @dump.nil?
                    @dump.format = @dump.format.to_sym
                end
            end
            
        end
                
    end
end
