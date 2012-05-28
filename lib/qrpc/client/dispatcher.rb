# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/general"
require "qrpc/client/job"
require "hash-utils/object"   # >= 1.1.0

##
# General QRPC module.
#

module QRPC
    
    ##
    # Queue RPC client.
    #
    # @note Since 0.3.0, all non-system methods was moved to the 
    #   {Dispatcher} module for maximal avoiding the user API 
    #   name conflicts.
    # @since 0.2.0
    #
    
    class Client
    
        ##
        # Queue RPC client dispaxtcher (worker).
        # @since 0.3.0
        #
        
        class Dispatcher
          
            ##
            # Holds current protocol object.
            #
            
            @protocol

            ##
            # Holds locator of the target queue.
            #
            
            @locator

            ##
            # Holds generator of IDs.
            #
            
            @generator
                        
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
            # Indicates, results pooling is ran.
            #
            
            @pooling
            
            ##
            # Holds clients for finalizing.
            #
            
            @@clients = { }
            
            ##
            # Constructor.
            #
            # @param [QRPC::Locator] locator of the output queue
            # @param [QRPC::Generator] ID generator
            # @param [QRPC::Protocol::Abstract] protocol protocol of the session
            #
            
            def initialize(locator, generator = QRPC::default_generator, protocol = QRPC::default_protocol)
                @protocol = protocol
                @locator = locator
                @generator = generator
                @pooling = false
                @jobs = { }

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
                    @input_queue.subscribe("default") do
                        @input_queue.unsubscribe(@input_name.to_s) do
                            @input_queue.close!
                        end
                    end
                end
                
                if not @output_queue.nil?
                    @output_queue.use("default") do
                        @output_queue.close!
                    end
                end
            end
                        
            ##
            # Creates job associated to this client session.
            # 
            # @param [Symbol] name name of the method of the job
            # @param [Array] args arguments of the method call
            # @param [Integer] priority job priority
            # @param [Proc] block result returning callback
            # @return [QRPC::Client::Job] new job
            #
            
            def create_job(name, args, priority = QRPC::DEFAULT_PRIORITY, &block)
                Client::Job::new(self.id, name, args, priority, @generator, @protocol, &block)
            end
            
            ##
            # Puts job to client.
            # @param [QRPC::Client::Job] job  job for put to output queue
            
            def put(job)
                if not job.notification?
                    id = job.id
                    id = id.to_sym if not id.kind_of? Integer
                    
                    @jobs[id] = job
                end
                
                if (not @pooling) and (@jobs.length > 0)
                    self.pool!
                end
                
                self.output_queue do |queue|
                    queue.push(job.serialize)
                end
            end
         
            ##
            # Starts input (results) pooling.
            #
            
            def pool!
                
                # Results processing logic
                processor = Proc::new do |job|
                    response = @protocol.response::parse(job)
                    
                    if not response.id.nil?
                        id = response.id
                        id = id.to_sym if not id.kind_of? Integer
                        
                        if @jobs.include? id
                            @jobs[id].assign_result(response)
                            @jobs.delete(id)
                        end
                    end
                end
                
                # Runs processor for each job (expects recurring #pop)   
                self.input_queue do |queue|
                    queue.pop(true, &processor)
                end
                
                ##
                
                @pooling = true
                
            end
            
            ##
            # Returns input name.
            # @return [Symbol] input queue name
            #
            
            def input_name
                if @input_name.nil?
                    @input_name = (QRPC::QUEUE_PREFIX + "-" + self.id.to_s + "-" + QRPC::QUEUE_POSTFIX_OUTPUT).to_sym
                else
                    @input_name
                end
            end
            
            ##
            # Returns input queue.
            # @param [Proc] block block to which will be input queue given
            #
            
            def input_queue(&block)
                if @input_queue.nil?
                    @input_queue = @locator.input_queue
                    @input_queue.subscribe(self.input_name.to_s) do
                        @input_queue.unsubscribe("default") do
                            yield @input_queue 
                        end
                    end
                else
                    @input_queue.subscribe(self.input_name.to_s) do
                        yield @input_queue
                    end
                end
            end
            
            ##
            # Returns output name.
            # @return [Symbol] output queue name
            #
            
            def output_name
                if @output_name.nil?
                    @output_name = (QRPC::QUEUE_PREFIX + "-" + @locator.queue_name + "-" + QRPC::QUEUE_POSTFIX_INPUT).to_sym
                else
                    @output_name
                end
            end
            
            ##
            # Returns output queue.
            # @param [Proc] block block to which will be output queue given
            #
            
            def output_queue(&block)
                if @output_queue.nil?
                    @output_queue = @locator.output_queue
                    @output_queue.use(self.output_name.to_s) do
                        yield @output_queue
                    end
                else
                    @output_queue.use(self.output_name.to_s) do
                        yield @output_queue
                    end
                end
            end
            
            ##
            # Returns client (or maybe session is better) ID.
            # @return [Symbol] client (session) ID
            #
            
            def id
                if @id.nil?
                    @id = @generator.generate(self)
                else
                    @id
                end
            end
               
        end
                
    end
end
