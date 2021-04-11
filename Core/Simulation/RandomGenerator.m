classdef RandomGenerator < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        seed
        currentseed
    end
    
    methods
        function obj = RandomGenerator(seed)
            obj.seed = seed;
            obj.init();
        end
        
        function init(obj)
            obj.currentseed = obj.seed;
        end
        
        function turnOn(obj)
            rng(obj.currentseed);
        end
        
        function turnOff(obj)
            obj.currentseed = rng;
        end
            
    end
    
end

