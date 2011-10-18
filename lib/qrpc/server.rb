# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/general"
require "qrpc/server/job"
require "qrpc/server/dispatcher"
require "qrpc/locator"
require "qrpc/protocol/qrpc-object"
require "hash-utils/hash"   # >= 0.1.0
require "em-jack"
require "eventmachine"
require "base64"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Queue RPC server.
    #
    
    class Server

        ##
        # Prefix for handled queues.
        # @deprecated (since 0.2.0)
        #
        
        QRPC_PREFIX = QRPC::QUEUE_PREFIX
        
        ##
        # Input queue postfix.
        # @deprecated (since 0.2.0)
        #
        
        QRPC_POSTFIX_INPUT = QRPC::QUEUE_POSTFIX_INPUT
        
        ##
        # Output queue postfix.
        # @deprecated (since 0.2.0)
        #
        
        QRPC_POSTFIX_OUTPUT = QRPC::QUEUE_POSTFIX_OUTPUT

        ##
        # Holds API instance.
        #
        
        @api
        
        ##
        # Holds input locator.
        #
        
        @locator
        
        ##
        # Holds input queue name.
        #
        
        @input_name
        
        ##
        # Holds output queue name.
        #
        
        @output_name
        
        ##
        # Holds input queue instance.
        #
        
        @input_queue
        
        ##
        # Holds output queue instance.
        #
        
        @output_queue
        
        ##
        # Holds job dispatcher.
        #
        
        @dispatcher
        
        ##
        # Cache of output names.
        #
        
        @output_name_cache
        
        ##
        # Indicates currently used output queue.
        #
        
        @output_used
        
        ##
        # Holds data serializer.
        # @since 0.4.0
        #
        
        @serializer
        
        ##
        # Indicates API methods synchronicity.
        # @since 0.4.0
        #
        
        @synchronicity
        
        ##
        # Holds servers for finalizing.
        #
        
        @@servers = { }

        ##
        # Constructor.
        #
        # @param [Object] api some object which will be used as RPC API
        # @param [Symbol] synchronicity  API methods synchronicity
        # @param [JsonRpcObjects::Serializer] serializer  data serializer
        #
        
        def initialize(api, synchronicity = :synchronous, serializer = QRPC::default_serializer)
            @api = api
            @serializer = serializer
            @synchronicity = synchronicity
            @output_name_cache = { }
            
            # Destructor
            ObjectSpace.define_finalizer(self, self.class.method(:finalize).to_proc)
            @@servers[self.object_id] = self
        end
        
        ##
        # Finalizer handler.
        # @param [Integer] id id of finalized instance
        #
        
        def self.finalize(id)
            if @@servers.has_key? id
                @@servers[id].finalize!
            end
        end
        
        ##
        # Destructor.
        #
        
        def finalize!
            if not @input_queue.nil?
                @input_queue.watch("default") do
                    @input_queue.ignore(@input_name.to_s) do
                        @input_queue.close
                    end
                end
            end
            
            if not @output_queue.nil?
                @output_queue.use("default") do
                    @output_queue.close
                end
            end
        end
        

        ##
        # Listens to the queue.
        # (Blocking call which starts eventmachine.)
        #
        # @param [QRPC::Locator] locator of the input queue
        # @param [Hash] opts options for the server
        #

        def listen!(locator, opts = { })
            EM.run do
                self.start_listening(locator, opts)
            end
        end
        
        ##
        # Starts listening to the queue.
        # (Blocking queue which expect, eventmachine is started.)        
        #
        # @param [QRPC::Locator] locator of the input queue
        # @param [Hash] opts options for the server
        #
        
        def start_listening(locator, opts = { })
            @locator = locator
            @dispatcher = QRPC::Server::Dispatcher::new

            # Cache cleaning dispatcher
            EM.add_periodic_timer(20) do
                @output_name_cache.clear
            end
            
            # Process input queue
            self.input_queue do |queue|
                worker = Proc::new do
                    @dispatcher.available? do
                        queue.reserve do |job|
                            self.process_job(job)
                            job.delete()
                            worker.call()
                        end
                    end
                end
                
                worker.call()
            end
        end
        
        ##
        # Returns input queue.
        # @param [Proc] block block to which will be input queue given
        #
        
        def input_queue(&block)
            if not @input_queue
                @input_queue = EMJack::Connection::new(:host => @locator.host, :port => @locator.port)
                @input_queue.watch(self.input_name.to_s) do
                    @input_queue.ignore("default") do
                        block.call(@input_queue)
                    end
                end
            else
                block.call(@input_queue)
            end
        end
        
        ##
        # Returns output queue.
        # @return [EMJack::Connection] output queue Beanstalk connection
        #
        
        def output_queue
            if @output_queue.nil?
                @output_queue = EMJack::Connection::new(:host => @locator.host, :port => @locator.port)
            end
            
            return @output_queue
        end
        
        ##
        # Returns output name for client name.
        #
        # @param [String, Symbol] client  client identifier
        # @return [Symbol] output name
        #
        
        def output_name(client)
            client_index = client.to_sym
            
            if not @output_name_cache.include? client_index
               output_name = QRPC::QUEUE_PREFIX + "-" + client.to_s + "-" + QRPC::QUEUE_POSTFIX_OUTPUT
               output_name = output_name.to_sym
               @output_name_cache[client_index] = output_name
            else
                output_name = @output_name_cache[client_index]
            end
               
            return output_name
        end
        
        ##
        # Returns input name.
        #
        # @return [Symbol] input name
        # @since 0.1.1
        #
        
        def input_name
            if @input_name.nil?
                @input_name = (QRPC::QUEUE_PREFIX + "-" + @locator.queue + "-" + QRPC::QUEUE_POSTFIX_INPUT).to_sym
            end
            
            return @input_name
        end
        
        
        
        protected
        
        ##
        # Process one job.
        #
        
        def process_job(job)
            our_job = QRPC::Server::Job::new(@api, @synchronicity, job, @serializer)
            our_job.callback do |result|
                call = Proc::new { self.output_queue.put(result, :priority => our_job.priority) }
                output_name = self.output_name(our_job.client)
                
                if @output_used != output_name 
                    @output_used = output_name
                    self.output_queue.use(output_name.to_s, &call)
                else
                    call.call
                end
            end
            
            @dispatcher.put(our_job)
        end
        
    end
end
