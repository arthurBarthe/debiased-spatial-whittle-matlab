classdef StandardizeOperator < SampleOperator
    %This class defines the structure for defining an operator that returns
    %a new sample with mean 0 and variance 1.
    
    properties
        
    end
    
    methods
        function obj = StandardizeOperator()
            obj@SampleOperator('Standardizing Operator');
        end
    end
    
    methods (Access = protected)
        function new_sample = apply_(obj, sample)
            %Returns a new sample with mean zero and unit variance
            std_ = sample_std(sample);
            new_sample = (sample - sample_mean(sample)) / std_;
        end
    end
    
end

