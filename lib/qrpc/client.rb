# encoding: utf-8
require "json-rpc-objects/request"

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
            self.put(Client::Job::new(client.id, name, args, block))
        end
        
        ##
        # Puts job to client.
        #
        
        def put(job)
            @jobs[job.id] = job
            
            self.output_queue do |queue|
                queue.put(job.to_json)
            end
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
                @output_queue.ignore("default") do
                    @output_queue.use(QRPC::QUEUE_PREFIX.dup << "-" << @locator.queue << "-" << QRPC::QUEUE_POSTFIX_INPUT) do
                        block.call(@output_queue)
                    end
                end
            else
                block.call(@output_queue)
            end
        end
                
    end
end
