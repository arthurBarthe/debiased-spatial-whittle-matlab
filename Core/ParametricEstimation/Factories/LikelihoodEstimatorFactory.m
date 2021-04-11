classdef LikelihoodEstimatorFactory < ParameterEstimatorFactory
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        optimization_options
        initial_estimator_factory    
        init_est_choice
        optimization_func
    end
    
    properties (Constant)
        default_options = optimset('GradObj','on','MaxFunEvals',100000,...
            'MaxIter',100,'TolFun',1e-10,'TolX',1e-4,'Display','off');
        default_optimization_func = @fminsearch;
    end
    
    methods
        function obj = LikelihoodEstimatorFactory(init_est_factory, ...
                init_est_choice, optimization_func, options)
            switch nargin
                case 0
                    error(['An initial estimator must be passed, ' ...
                        'for the optimization procedure to be ' ...
                        'initizialised.']);
                case 1
                    init_est_choice = '';
                    optimization_func = obj.default_optimization_func;
                    options = obj.default_options;
                case 2
                    optimization_func = obj.default_optimization_func;
                    options = obj.default_options;
                case 3
                    options = obj.default_options;
            end
            obj.init_est_choice = init_est_choice;
            obj.optimization_options = options;
            obj.initial_estimator_factory = init_est_factory;
            obj.optimization_func = optimization_func;
        end
        
        function estimator = get_estimator(obj, grid, choice)
            estimator = get_estimator@ParameterEstimatorFactory(obj, ...
                grid, choice);
            estimator.optimization_options = obj.optimization_options;
            initial_est = obj.initial_estimator_factory.get_estimator(...
                grid, obj.init_est_choice);
            estimator.initial_guess_estimator = initial_est;
            estimator.optimization_func = obj.optimization_func;
        end
    end
end

