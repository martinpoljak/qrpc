# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "hash-utils/object"  # >= 1.1.0

##
# General QRPC module.
#

module QRPC
    
    ##
    # General generators module.
    # @since 0.9.0
    #
    
    module Generator
      
        ##
        # Ruby object ID generator.
        # @since 0.9.0
        #
        
        class ObjectID
          
            ##
            # Generates Ruby object ID as ID for given object.
            #
            # @param [Object] object  required object
            # @return [Symbol] new ID
            #
            
            def generate(object)
                object.object_id
            end
            
            alias :generate! :generate
            
        end
        
    end
    
end