# encoding: utf-8
require "em-beanstalk"

EM::run do
    q = EM::Beanstalk::new
        
    j = q.each_job(2) do
        puts "x"
    end
    
    j.on_error do |x|
        puts x.inspect
    end
    
    puts "y"
    
    fiber = EM.spawn do 
        puts "spawn"
    end
    
    puts fiber.notify.inspect
end
