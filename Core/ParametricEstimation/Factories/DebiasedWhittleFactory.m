classdef DebiasedWhittleFactory < ParameterEstimatorFactory
    properties
    end
    
    methods
        function estimator = get_estimator(obj, grid, choice)
            estimator = DeBiasedWhittle();
            estimator.grid = grid;
        end
    end
end