classdef ConstantEstimator < ParameterEstimator
    %This class just defines the structure for an estimator that returns
    %constants. Used for initial guesses of likelihood estimators for
    %instance when we're not using data-dependent methods.
    
    properties
        constants
        range_param_id
    end
    
    methods
        function obj = ConstantEstimator()
            %Args
            %constants should be a vector of constants returned by this
            %estimator, expect for the range parameter that will be taken
            %to be half the grid's width.
            %range_param_id indicates which of the parameters is the range
            %parameter.
            obj@ParameterEstimator('Constant');
        end
        
        function estimate(obj, sample, model)
            params = obj.constants;
            g_rect = sample.grid.grid;
            params(obj.range_param_id) = g_rect.get_diameter() / 2;
            model.setParameters(params);
        end
        
        function t = getCPUtime(obj)
            t = 0;
        end
        
        function get_residuals(obj, model, sample)
            error('Not implemented for this estimator');
        end
    end
    
end

