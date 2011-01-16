# encoding: utf-8
require "qrpc/job"
require "qrpc/dispatcher"
require "qrpc/locator"
require "em-beanstalk"
require "eventmachine"
require "base64"

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
        # Holds job dispatcher.
        #
        
        @dispatcher
        
        ##
        # Holds servers for finalizing.
        #
        
        @@servers = { }

        ##
        # Constructor.
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
        # (Blocking call which starts eventmachine.)
        #

        def listen!(locator, opts = { })
            EM::run do
                self.start_listening(locator, opts)
            end
        end
        
        ##
        # Starts listening to the queue.
        # (Blocking queue which expect, eventmachine is started.)
        #
        
        def start_listening(locator, opts)
            @locator = locator
            @locator.queue = self.class::QRPC_PREFIX.dup << "-" << @locator.queue << "-" << self.class::QRPC_POSTFIX_INPUT
            @dispatcher = QRPC::Server::Dispatcher::new(opts[:max_jobs])

            self.input_queue do |queue|
                queue.each_job do |job|
                    self.process_job(job)
                end
            end
        end
        
        ##
        #
        
        ##
        # Returns input queue.
        # (Callable from EM only.)
        #
        
        def input_queue(&block)
            if not @input_queue
                @input_queue = EM::Beanstalk::new(:host => @locator.host, :port => @locator.port)
                @input_queue.watch(@locator.queue) do
                    @input_queue.ignore("default") do
                        block.call(@input_queue)
                    end
                end
            end
            
            block.call(@input_queue)
        end
        
        ##
        # Returns output queue.
        # (Callable from EM only.)
        #
        
        def output_queue
            if not @output_queue
                @output_queue = EM::Beanstalk::new(:host => @locator.host, :port => @locator.port)
            end
            
            return @output_queue
        end
        
        
        protected
        
        ##
        # Process one job.
        #
        
        def process_job(job)
            our_job = QRPC::Server::Job::new(@api, job) 
            our_job.callback do |result|
                call = Proc::new { self.output_queue.put(result[:output]) }
                output_name = self.class::QRPC_PREFIX.dup << "-" << result[:client] << "-" << self.class::QRPC_POSTFIX_OUTPUT
                
                self.output_queue.list(:used) do |used|
                    if used != output_name 
                        self.output_queue.use(output_name, &call)
                    else
                        call.call
                    end
                end
            end
            
            @dispatcher.put(our_job)
        end
        
    end
end
