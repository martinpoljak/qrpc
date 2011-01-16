# encoding: utf-8
require "depq"

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
            # Constructor.
            #
            
            def initialize(max_jobs = 20)
                @count = 0
                @queue = Depq::new
                @max_jobs = max_jobs
                
                if @max_jobs.nil?
                    @max_jobs = 20
                end
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
                
                if @count < @max_jobs
                    self.process_next!
                    @count += 1
                end
            end
            
            ##
            # Sets up next job for processing.
            #
            
            def process_next!
                job = @queue.pop
                job.callback do
                    if (@count < @max_jobs) and not @queue.empty?
                        self.process_next!
                    else
                        @count -= 1
                    end
                end

                job.process!
            end
            
        end
    end
end
