# encoding: utf-8
require "depq"
require "options-hash"

##
# General QRPC module.
#

module QRPC
    class Server
        
        ##
        # Queue RPC job.
        #
        
        class Dispatcher
        
            ##
            # Holds running EM fibers count.
            #
            
            @count
            
            ##
            # Holds unprocessed jobs queue.
            #
            
            @queue
            
            ##
            # Holds max jobs count.
            #
            
            @max_jobs
                    
            ##
            # Holds "full state" locking mutex.
            #
            
            @mutex
            
            ##
            # Constructor.
            # @param [Hash] opts  array of options
            #
            
            def initialize(opts = { })
                @count = 0
                @queue = Depq::new
                @mutex = Mutex::new
                
                opts = OptionsHash::get(opts)[
                    :max_jobs => 20
                ];
                
                @max_jobs = opts.max_jobs
            end
            
            ##
            # Puts job to dispatcher.
            # @param [QRPC::Server::Job] job job for dispatching
            #
            
            def put(job)
                begin
                    @queue.put(job, job.priority)
                rescue ::Exception => e
                    return
                end
                
                if self.available?
                    self.process_next!
                    @count += 1
                    self.regulate!
                end
            end
            
            ##
            # Sets up next job for processing.
            #
            
            def process_next!
                job = @queue.pop
                job.callback do
                    if self.available? and not @queue.empty?
                        self.process_next!
                    else
                        @count -= 1
                        self.regulate!
                    end
                end

                job.process!
            end
            
            ##
            # Indicates free space is available in dispatcher.
            #
            # If block is given, locks to time space in dispatcher is 
            # available so works as synchronization primitive by this 
            # way.
            #
            # @overload available?
            #   @return [Boolean] +true+ if it is, +false+ in otherwise
            # @overload available?(&block)
            #   @param [Proc] block synchronized block
            #
            
            def available?(&block)
                if block.nil?
                    return ((@count < @max_jobs) or (@max_jobs == 0))
                else
                    @mutex.synchronize(&block)
                end
            end
            
            
            protected
            
            ##
            # Regulates by locking the dispatcher it if it's full.
            #
            
            def regulate!
                if self.available?
                    if @mutex.locked?
                        @mutex.unlock
                    end
                else
                    @mutex.try_lock
                end
            end
            
        end
    end
end
