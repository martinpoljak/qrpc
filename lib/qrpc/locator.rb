# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "qrpc/locator/em-jack"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Resource locator.
    # @deprecated (since 0.9.0) in favour to locators for each queue types
    #
    
    module Locator
      
        ##
        # Returns new instance of {EMJackLocator}.
        # @returns [EMJackLocator]
        #
         
        def self.new(*args, &block)
            EMJackLocator::new(*args, &block)
        end
        
    end
        
end
