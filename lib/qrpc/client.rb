# encoding: utf-8
require "em-beanstalk"
require "uuid"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Queue RPC client.
    #
    
    class Client
    
        ##
        # Holds locator of the target queue.
        #
        
        @locator
        
        ##
        # Holds client session ID.
        #
        
        @id
        
        ##
        # Holds input queue name.
        #
        
        @input_name
        
        ##
        # Holds input queue instance.
        #
        
        @input_queue
        
        ##
        # Holds output queue name.
        #
        
        @output_name
        
        ##
        # Holds output queue instance.
        #
        
        @output_queue
        
        ##
        # Holds clients for finalizing.
        #
        
        @@clients = { }
        
        ##
        # Constructor.
        #
        
        def initialize(locator)
            @locator = locator
        
            # Destructor
            ObjectSpace.define_finalizer(self, self.class.method(:finalize).to_proc)
            @@clients[self.object_id] = self
        end
        
        ##
        # Finalizer handler.
        # @param [Integer] id id of finalized instance
        #
        
        def self.finalize(id)
            if @@clients.has_key? id
                @@clients[id].finalize!
            end
        end
        
        ##
        # Destructor.
        #
        
        def finalize!
            if not @input_queue.nil?
                @input_queue.watch("default") do
                    @input_queue.ignore(@input_name) do
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
        # *********
        # Handles call to RPC.
        #
        # Be warn, arguments will be serialized to JSON, so they should
        # be serializable nativelly or implement +#to_json+ method.
        #
        
        def method_missing(name, *args, &block)
            self.put(Client::Job::new(self.id, name, args, block))
        end
        
        ##
        # Puts job to client.
        #
        
        def put(job)
            @jobs[job.id] = job
            
            self.output_queue do |queue|
                queue.put(job.to_json)
            end
            
            if @jobs.length > 0
                self.pool!
            end
        end
        
        ##
        # Starts input (results) pooling.
        #
        
        def pool!
            
            # Results processing logic
            processor = Proc::new do |job|
            end
            
            # Runs processor for each job, if no job available
            #   and any results came, terminates pooling. In 
            #   otherwise restarts pooling.

            worker = EM.spawn do                
                self.input_queue do |queue|
                    queue.each_job(4, &processor).on_error do |error|
                        if error == :timed_out
                            if @jobs.length > 0
                                self.pool!
                            end
                        else
                            raise Exception::new("Beanstalk error: " << error.to_s)
                        end
                    end
                end
            end
            
            ##
            
            worker.run
        end
        
        ##
        # Returns input name.
        #
        
        def input_name
            if @input_name.nil?
                @input_name = (QRPC::QUEUE_PREFIX.dup << "-" << self.id << "-" << QRPC::QUEUE_POSTFIX_OUTPUT).to_sym
            end
            
            return @input_name
        end
        
        ##
        # Returns input queue.
        # (Callable from EM only.)
        #
        # @return [EM::Beanstalk] input queue Beanstalk connection
        #
        
        def input_queue(&block)
            if @input_queue.nil?
                @input_queue = EM::Beanstalk::new(:host => @locator.host, :port => @locator.port)
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
        # Returns output name.
        #
        
        def output_name
            if @output_name.nil?
                @output_name = (QRPC::QUEUE_PREFIX.dup << "-" << @locator.queue << "-" << QRPC::QUEUE_POSTFIX_INPUT).to_sym
            end
            
            return @output_name
        end
        
        ##
        # Returns output queue.
        # (Callable from EM only.)
        #
        # @return [EM::Beanstalk] output queue Beanstalk connection
        #
        
        def output_queue(&block)
            if @output_queue.nil?
                @output_queue = EM::Beanstalk::new(:host => @locator.host, :port => @locator.port)
                @output_queue.use(self.output_name.to_s) do
                    block.call(@output_queue)
                end
            else
                block.call(@output_queue)
            end
        end
        
        ##
        # Returns client (or maybe session is better) ID.
        #
        
        def id
            if @id.nil?
                @id = UUID.generate
            end
            
            return @id
        end
                
    end
end
