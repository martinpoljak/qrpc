# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "priority_queue/c_priority_queue"
require "hash-utils/array"
require "unified-queues"
require "evented-queue"
require "em-wrapper"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Resource locators.
    #
    
    module Locator
      
        ##
        # Locator for 'evented-queue' queue type.
        # @see https://github.com/martinkozak/evented-queue
        # 
        
        class EventedQueueLocator
            
            ##
            # Contains queue name.
            # @return [String]
            #
    
            attr_accessor :queue_name
            @queue_name
            
            ##
            # Contains queue instance.
            # @return [EventedQueue::Recurring]
            #
    
            attr_accessor :queue
            @queue
            
            ##
            # Constructor.
            # @param [EventedQueue::Recurring] queue  recurring evented queue instance
            #
            
            def initialize(queue_name, queue = self.default_queue)
                @queue = queue
                @queue_name = queue_name
            end
            
            ##
            # Returns the default evented queue type.
            #
            
            def default_queue 
                UnifiedQueues::Multi::new UnifiedQueues::Single, ::EM::Wrapper::new(REUQ),  UnifiedQueues::Single, CPriorityQueue
=begin
                 do |c|
                    EM::next_tick do
                        c.call()
                    end
                end
=end
            end
            
            alias :input_queue :queue
            alias :output_queue :queue
        
            
            ##
            # Helper recurring evented queue with unified queues support.
            #
        
            class REUQ < ::EventedQueue::Recurring
                def initialize(*args)
                    cls = args.first
                    args.shift
                    object = cls::new(*args)
                    super(object)
                end
            end    
        end
    end
end

=begin
q = QRPC::Locator::EventedQueue::new
q.input_queue.use(:xyz)
q.queue.push(:x, 2)
q.queue.push(:y, 3)
q.queue.subscribe(:xyz)
q.queue.pop do |i|
    p i
end
q.queue.push(:z, 1)
=end