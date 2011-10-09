# encoding: utf-8
require "priority_queue/c_priority_queue"

##
# General QRPC module.
#

module QRPC
  
    ##
    # Queue RPC server.
    #
    
    class Server
        
        ##
        # Queue RPC job.
        #
        
        class Dispatcher
        
            ##
            # Holds unprocessed jobs queue.
            #
            
            @queue
            
            ##
            # Constructor.
            # @param [Hash] opts  array of options
            #
            
            def initialize(opts = { })
                @queue = CPriorityQueue::new
            end
            
            ##
            # Puts job to dispatcher.
            # @param [QRPC::Server::Job] job job for dispatching
            #
            
            def put(job)
                begin
                    @queue.push(job, -job.priority)
                rescue ::Exception => e
                    return
                end
                
                if self.available?
                    self.process_next!
                end
            end
            
            ##
            # Sets up next job for processing.
            #
            
            def process_next!
                job = @queue.delete_min_return_key
                job.callback do
                    if self.available? 
                        if not @queue.empty?
                            self.process_next!
                        end
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
                    true
                else
                    yield
                end
            end
            
        end
    end
end
