classdef ExactLikelihoodFactory < ParameterEstimatorFactory
    properties
    end
    
    methods
        function estimator = get_estimator(obj, grid, choice)
            estimator = ExactLikelihood();
            estimator.grid = grid;
        end
    end
end