# encoding: utf-8
require "qrpc/job"
require "qrpc/dispatcher"

module QRPC
    
    ##
    # Queue RPC server.
    #
    
    class Server
    
        ##
        # Prefix for handled queues.
        #
        
        QRPC_PREFIX = "qrpc"
        
        ##
        # Input queue postfix.
        #
        
        QRPC_POSTFIX_INPUT = "input"
        
        ##
        # Output queue postfix.
        #
        
        QRPC_POSTFIX_OUTPUT = "output"

        ##
        # Holds API instance.
        #
        
        @api
        
        ##
        # Holds input locator.
        #
        
        @locator
        
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
        # Holds servers for finalizing.
        #
        
        @@servers = { }

        ##
        # Constructor.
        # Initializes unthreaded by default.
        #
        
        def initialize(api)
            @api = api
            
            # Destructor
            ObjectSpace.define_finalizer(self, self.class.method(:finalize).to_proc)
            @@servers[self.object_id] = self
        end
        
        ##
        # Finalizer handler.
        #
        
        def self.finalize(id)
            if @@servers.has_key? id
                @@servers[id].finalize!
            end
        end
        
        ##
        # Destructor
        #
        
        def finalize!
            if @input_queue
                @input_queue.watch("default") do
                    @input_queue.ignore(@input_name) do
                        @input_queue.close
                    end
                end
            end
            
            if @output_queue
                @output_queue.use("default") do
                    @output_queue.close
                end
            end
        end
        

        ##
        # Listens to the queue.
        # Blocking call.
        #

        def listen!(locator, opts = { })
            qrpc_prefix = self.class::QRPC_PREFIX
            qrpc_postfix_output = self.class::QRPC_POSTFIX_OUTPUT
            dispatcher = QRPC::Server::Dispatcher::new(opts[:max_jobs])
            
            @locator = locator
            @locator.queue = qrpc_prefix.dup << "-" << @locator.queue << "-" << self.class::QRPC_POSTFIX_INPUT
            
            EM::run do
                self.input_queue.each_job do |job|
                    our_job = QRPC::Server::Job::new(job) 
                    our_job.callback do |result|
                        output_queue.use(qrpc_prefix.dup << "-" << result[:client] << "-" << qrpc_postfix_output) do
                            output_queue.put(result[:output])
                        end
                    end
                    
                    dispatcher.put(our_job)
                end
            end
        end
        
        ##
        # Returns input queue.
        # (Callable from EM only.)
        #
        
        def input_queue
            if not @input_queue
                @input_queue = EM::Beanstalk::new([@locator.host])
                @input_queue.watch(@locator.queue) do
                    @input_queue.ignore("default") do
                        return @input_queue
                    end
                end
            end
            
            return @input_queue
        end
        
        ##
        # Returns output queue.
        # (Callable from EM only.)
        #
        
        def output_queue
            if not @output_queue
                @output_queue = EM::Beanstalk::new([@locator.host])
            end
            
            return @output_queue
        end
        
    end
end
