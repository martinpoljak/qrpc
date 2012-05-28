# encoding: utf-8
# (c) 2011-2012 Martin Kozák (martinkozak@martinkozak.net)

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
            # Puts job to dispatcher.
            # @param [QRPC::Server::Job] job job for dispatching
            #
            
            def put(job)
                job.process!
            end
            
        end
    end
end
