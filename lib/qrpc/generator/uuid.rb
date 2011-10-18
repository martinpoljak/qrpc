# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "uuid"

##
# General QRPC module.
#

module QRPC
    
    ##
    # General generators module.
    #
    
    module Generator
      
        ##
        # UUID generator.
        # @since 0.9.0
        #
        
        class UUID
          
            ##
            # Generates UUID as ID for given object.
            #
            # @param [Object] object  required object
            # @return [String] new ID
            # @since 0.9.0
            #
            
            def generate(object = nil)
                ::UUID.generate(:compact).to_sym
            end
            
            alias :generate! :generate
            
        end
        
    end
    
end