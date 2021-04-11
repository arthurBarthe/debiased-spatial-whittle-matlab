classdef MeanEstimator < Estimator
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = MeanEstimator()
            obj@Estimator('Mean estimator');
        end
        
        function est = compute(obj, sample)
            est = mean(sample.get_values());
        end
    end
    
end

