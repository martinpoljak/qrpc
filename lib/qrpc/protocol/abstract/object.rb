# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "abstract"
require "hashie/mash"
require "qrpc/general"
require "qrpc/protocol/abstract"

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
        # @since 0.9.0
        #
        
        class Abstract
        
            ##
            # Abstract request implementation.
            # @sice 0.9.0
            #
            
            class Object
              
                ##
                # Holds the object options.
                # @return [Hashie::Mash]  options hash
                #
                
                attr_accessor :options
                @options
                
                ##
                # Holds the object initial options.
                #
                
                @init
                
                ##
                # Constructor.
                #
                # @param [Hash] init  initial options
                # @abstract
                #
                
                def initialize(init = { })
                    @init = init
                    if self.instance_of? Object
                        not_implemented
                    end
                end
                
                ##
                # Assigns options to the object.
                # @param [Hash] options  hash with options
                # 
                
                def assign_options(options = { })
                    @options = Hashie::Mash::new(@init.merge(options))
                end
                
                ##
                # Serializes object to the resultant form.
                #
                # @return [String]  derialized form
                # @abstract
                #
                
                def serialize
                    not_implemented
                end
            end
        end
    end
end