# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "hash-utils/object"
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
            # Holds classes to modules assignment cache.
            # 
            
            @module_cache
                    
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
            # @return [Class]  class of the request object
            #
            
            def request
                __module(:Request)
            end
            
            ##
            # Returns new response object.
            # @return [Class]  class of the response object
            #
            
            def response
                __module(:Response)
            end
            
            ##
            # Returns new error object.
            # @return [Class]  class of the error object
            #
            
            def error
                __module(:Error)
            end
                        

            private
            
            ##
            # Returns class from module according to specific driver
            def __module(name)
                mod = Module.get_module(self.class.name + "::" + name.to_s)
                
                if not mod.in? @module_cache
                    cls = Class::new(mod)
                    opt = @options
                    
                    cls.class_eval do
                        define_method :initialize do |options = { }, &block|
                            super(opt.merge(options), &block)
                        end
                    end

                    @module_cache[mod] = cls                    
                else
                    
                @module_cache[mod]
            end
            
        end       
    end
end