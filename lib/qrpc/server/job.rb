# encoding: utf-8
require "eventmachine"
require "json-rpc-objects/request"
require "json-rpc-objects/response"
require "json-rpc-objects/error"
require "qrpc/general"
require "qrpc/protocol/qrpc-object"
require "qrpc/protocol/exception-data"


##
# General QRPC module.
#

module QRPC
    class Server

        ##
        # Queue RPC job.
        #
        
        class Job
            include EM::Deferrable
            
            ##
            # Indicates default priority.
            # @deprecated (since 0.2.0)
            #
            
            DEFAULT_PRIORITY = QRPC::DEFAULT_PRIORITY
            
            ##
            # Holds beanstalk job.
            #
            
            @job
            
            ##
            # Holds JSON-RPC request.
            #
            
            @request
            
            ##
            # Holds API object.
            #
            
            @api
            
            ##
            # Indicates API methods synchronicity.
            # @since 0.4.0
            #
            
            @synchronicity
            
            ##
            # Holds protocol handling instance.
            # @since 0.9.0
            #
            
            @protocol
            
            ##
            # Constructor.
            #
            # @param [Object] object which will serve as API
            # @param [Symbol] synchronicity  API methods synchronicity
            # @param [EM::Beanstalk::Job] job beanstalk job
            # @param [QRPC::Protocol::Abstract] protocol protocol handling instance
            #
            
            def initialize(api, synchronicity, job, protocol = QRPC::default_protocol)
                @synchronicity = synchronicity
                @protocol = protocol
                @job = job
                @api = api
            end
            
            ##
            # Starts processing.
            #
            
            def process!
                result = nil
                error = nil
                request = self.request
                
                if not request.notification?
                    finalize = Proc::new do
                        options = {
                            :result => result,
                            :error => error,
                            :request => request
                        }
                        
                        response = @protocol.response::new(options)
                        self.set_deferred_status(:succeeded, response.serialize)
                    end
                end

                
                if @synchronicity == :synchronous
                    begin
                        result = @api.send(request.method, *request.params)
                    rescue ::Exception => e
                        error = self.generate_error(request, e)
                    end
                    
                    if not request.notification?
                        finalize.call()
                    end
                else                
                    begin
                        @api.send(request.method, *request.params) do |res|
                            result = res
                            if not request.notification?
                                finalize.call()
                            end
                        end
                    rescue ::Exception => e
                        error = self.generate_error(request, e)
                        if not request.notification?
                            finalize.call()
                        end
                    end                    
                end
            end

            ##
            # Returns job in request form.
            # @return [JsonRpcObjects::Generic::Object] request associated to job
            #
            
            def request
                if @request.nil?
                    @request = @protocol.request::parse(@job)
                else
                    @request
                end
            end
            
            ##
            # Returns job priority according to request.
            #
            # Default priority is 50. You can scale up and down according
            # to your needs in fact without limits.
            #
            # @return [Integer] priority level
            #
            
            def priority
                priority = self.request.priority
                if priority.nil?
                    priority = QRPC::DEFAULT_PRIORITY
                else
                    priority = priority.to_i
                end
                
                return priority
            end
            
            ##
            # Returns client identifier.
            # @return [String] client identifier
            #
            
            def client
                self.request.client
            end
            
            
            protected
            
            ##
            # Generates error from exception.
            #
            
            def generate_error(request, exception)
                options = {
                    :exception => exception,
                    :request => request
                }
                
                @protocol.error::new(options)
            end
              
        end
    end
end
