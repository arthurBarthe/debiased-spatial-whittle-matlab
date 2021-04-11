classdef LikelihoodEstimator < ParameterEstimator
    %An abstract class for any likelihood estimator in the general sense,
    %i.e. one with a function to minimize, which is a "distance" between a
    %statistic computed on the sample (e.g. periodogram) and another
    %quantity (e.g. spectral density or expected periodogram). The Whittle
    %likelihood, the debiased Whittle likelihood, and the exact likelihood
    %all inherit from this class.
    
    properties
        constrained_optimization    %Unused for now. We use fminunc.
        optimization_options
        initial_guess_estimator     %An estimator to make the initial guess
        optimization_func
        last_sample
        cpu_time_initialization
        cpu_time
    end
    
    methods (Abstract)
        %The statistic to compute on the sample
        T = statistic(obj, sample)
        %The fitted quantity
        Tbar = Tbar(obj, model, sample)
        %The likelihood function
        likelihood = distance(obj, Tbar, T, sample)
    end
    
    methods
        function obj = LikelihoodEstimator(name)
            obj@ParameterEstimator(name);
            obj.optimization_func = @fminsearch;
            obj.last_sample = [];
            obj.initial_guess_estimator = 0;
            obj.cpu_time_initialization = 0;
            obj.cpu_time = 0;
        end
        
        function set_optimization_func(obj, func_handle)
            obj.optimization_func = func_handle;
        end
        
        function lkh = compute_likelihood(obj, sample, model)
            %Returns the likelihood value for the given model. This
            %function should not be used for optimization as the statistic
            %is comptue at each call.
            %TODO check if obj.Tbar should be replaced with obj.Tar_
            T = obj.statistic(sample);
            T_bar = obj.Tbar(model, sample);
            lkh = obj.distance(T_bar, T, sample);
        end
        
        function lkh_value = estimate(obj, sample, model)
            options = obj.optimization_options;
            tic;
            %Computation of the statistic (for instance, periodogram)
            T = obj.statistic(sample);
            if obj.initial_guess_estimator ~= 0
                obj.initial_guess_estimator.estimate(sample, model);
            end
            initial_guess = model.getParameters();
            nb_params = length(initial_guess);
            [params, lkh_value] = obj.optimization_func(...
                @(x)obj.distance(obj.fitted(x .* initial_guess, ...
                model, sample), T, sample), ones(1, nb_params), ...
                options);
            obj.cpu_time = toc + obj.cpu_time_initialization;
            model.setParameters(params .* initial_guess);
        end
        
        function Tbar = fitted(obj, x, model, sample)
            model.setParameters(x);
            Tbar = obj.Tbar_(model, sample);
        end
        
        function I = ObservedEstimationMatrix(obj, model, sample)
            %Returns the observed information matrix, using the
            %covariancefunction defined by the passed model.
            optim_func = obj.likelihood_function(model, sample);
            x = model.getParameters();
            H = hessian(optim_func, x);
            I = -inv(H);
        end
        
        function grad =  likelihood_gradient(obj, model, sample)
            %Returns the gradient of the likelihood at the value of the
            %parameters specified by the passed model.
            x = model.getParameters();
            grad = gradest(obj.likelihood_function(model, sample), x);
        end
        
        function handle = likelihood_function(obj, model, sample)
            %returns the likelihood function as a function handle.
            T = obj.statistic(sample);
            optim_func = @(x) obj.distance(obj.fitted(x, ...
                model, sample), T, sample);
            handle = optim_func;
        end
            
                
        function setInitial_guess_estimator(obj, estimator)
            obj.initial_guess_estimator = estimator;
        end
        
        function t = getCPUtime(obj)
            t = obj.cpu_time;
        end
    end
end

