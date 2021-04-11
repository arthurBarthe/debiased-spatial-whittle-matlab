classdef SampleOperator < handle
    %UNTITLED30 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
    end
    
    methods 
        function obj = SampleOperator(name)
            obj.name = name;
        end
        
        function new_op = plus(obj, obj2)
            %Retunrs a new operator, which first applies operator obj, and
            %then applies operator obj2.
            new_op = CombinedOperators(obj, obj2);
        end
        
        function sample_new = apply(obj, sample)
            sample_new = obj.apply_(sample);
            message = ['Applied operator ' obj.name ' to ' sample.name '.'];
%             disp(message);
        end
    end
    
    methods (Abstract, Access = protected)
        sample_new = apply_(obj, sample)
    end
    
end

