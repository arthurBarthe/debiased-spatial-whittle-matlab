classdef DeBiasedWhittle < WhittleTypeEstimator
    %This class defines the structure to represent the debiased Whittle
    %estimator.

    methods
        function obj=DeBiasedWhittle()
            obj@WhittleTypeEstimator('De-biased Whittle');
        end
        
        function Tbar = Tbar(obj, model, sample)
            Tbar = obj.periodogram.compute_expectation(model, sample);
        end
    end
    
end

