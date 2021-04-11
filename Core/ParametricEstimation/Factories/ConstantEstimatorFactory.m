classdef ConstantEstimatorFactory < ParameterEstimatorFactory
    properties
        constants
        range_param_id
    end
    
    methods
        function estimator = get_estimator(obj, grid, choice)
            estimator = ConstantEstimator();
            estimator.constants = obj.constants;
            estimator.grid = grid;
            estimator.range_param_id = obj.range_param_id;
        end
    end
end

