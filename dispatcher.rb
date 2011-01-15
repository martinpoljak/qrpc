# encoding: utf-8

module MNF
    module RPC
        module Queue
            
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
                # Constructor.
                #
                
                def initialize
                    @count = 0
                    @queue = [ ]
                end
                
                ##
                # Puts job to dispatcher.
                # @param [MNF::RPC::Queue::Job] job job for dispatching
                #
                
                def put(job)
                    @queue << job
                    
                    if @count < 20
                        self.process_next!
                        @count += 1
                    end
                end
                
                ##
                # Sets up next job for processing.
                #
                
                def process_next!
                    job = @queue.shift
                    job.callback do
                        if (@count < 20) and not @queue.empty?
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
end
