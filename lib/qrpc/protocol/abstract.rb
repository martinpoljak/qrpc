# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "hash-utils/module"
require "qrpc/general"
require "hashie/mash"
require "abstract"

##
# General QRPC module.
#

module QRPC
    
    ##
    # Protocols helper module.
    # @since 0.9.0
    #
    
    module Protocol

        ##
        # Abstract protocol implementation.
        #
        # @since 0.9.0
        # @abstract
        #
        
        class Abstract
          
            ##
            # Holds general object options.
            # @return [Hashie::Mash]  general options
            #
            
            attr_accessor :options
            @options
                    
            ##
            # Constructor.
            #
            # @param [Hash] options general options for submodules
            # @abstract
            #
            
            def initialize(options = { })
                @options = Hashie::Mash::new(options)
                if self.instance_of? Abstract
                    not_implemented
                end
            end
            
            ##
            # Returns new request object.
            # @param [Hash] options  options for the new instance
            #
            
            def request(options = { })
                __module(:Request)::new(@options.merge(options))
            end
            
            ##
            # Returns new response object.
            # @param [Hash] options  options for the new instance
            #
            
            def response(options = { })
                __module(:Response)::new(@options.merge(options))
            end
            
            ##
            # Returns new exception object.
            # @param [Hash] options  options for the new instance
            #
            
            def exception(options = { })
                __module(:ExceptionData)::new(@options.merge(options))
            end
            
            ##
            # Returns new QRPC object.
            # @param [Hash] options  options for the new instance
            #
            
            def qrpc(options = { })
                __module(:QrpcObject)::new(@options.merge(options))
            end
            

            private
            
            ##
            # Returns class from module according to specific driver
            def __module(name)
                Module.get_module(self.class.name + "::" + name.to_s)
            end
            
        end       
    end
end