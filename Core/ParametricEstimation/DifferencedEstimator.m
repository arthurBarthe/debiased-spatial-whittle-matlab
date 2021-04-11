classdef DifferencedEstimator < ParameterEstimator
    %This class defines the structure for an estimator that uses one
    %specified estimator on the differenced data.
    %Properties
    %estimator - ParameterEstimator - The estimator used on the differenced
    %data
    %cpu_time_differencing - double - The cpu time used for the last
    %estimation corresponding to the differencing operation on the data.
    
    properties
        estimator
        cpu_time_differencing
    end
    
    methods
        function obj = DifferencedEstimator(estimator)
            obj@ParameterEstimator([estimator.getName() ' + Differencing']);
            obj.estimator = estimator;
            obj.cpu_time_differencing = 0;
        end
        
        function estimate(obj, sample, model)
            %We first apply the differencing operator
            tic
            diff_op = DifferencingOperator();
            diff_sample = diff_op.apply(sample);
            %The fitted model will be the differenced model. Note that a
            %DifferencedModel does not provide a continuous covariance
            %function, but only the covariance function on a grid.
            diff_model = DifferencedModel(model);
            obj.cpu_time_differencing = toc;
            obj.estimator.estimate(diff_sample, diff_model);
        end
        
        function t = getCPUtime(obj)
            est_cpu_time = obj.estimator.getCPUtime();
            t = est_cpu_time + obj.cpu_time_differencing;
        end
    end
end

