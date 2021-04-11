classdef Estimator < handle
    %Abstract class for any estimator. In particular this defines the
    %signature of the function estimate. All estimators must also be given
    %a name, so that when a comparison of two estimators is carried out,
    %them two can be distinguished.
    
    properties
        name
    end
    
    methods (Abstract)
       est = compute(sample);
    end
    
    methods
        function obj = Estimator(name)
            obj.name = name;
        end
        
        function name = getName(obj)
            name = obj.name;
        end
    end
    
end

