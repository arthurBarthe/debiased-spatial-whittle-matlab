classdef EstimateWithOperator < ParameterEstimator
    %This class defines the structure for defining estimators that are the
    %combination of an operator that is applied to the sample before
    %conducting the estimation. For example, this allows to combine
    %differencing and debiased Whittle estimation. The expected periodogram
    %of the differenced process will be used automatically.
    %Properties:
    %estimator ParameterEstimator A parametric estimator to be used on the
    %data, once it has been processed with the operator.
    %operator SampleOperator The operator used to process the data. The
    %operator must define the method get_new_model.
    %cpu_time double cpu_time of the last estimation.
    
    properties
        estimator
        operator
        cputime
    end
    
    methods
        function obj = EstimateWithOperator(estimator, operator)
            name = [estimator.getName() ' + ' operator.name];
            obj@ParameterEstimator(name);
            obj.estimator = estimator;
            obj.operator = operator;
            obj.cputime = 0;
        end
        
        function estimate(obj, sample, model)
            %Carries out estimation by first applying the operator to the
            %sample, then determining the model for this new data, then
            %applying the estimator.
            tic;
            new_sample = obj.operator.apply(sample);
            new_model = obj.operator.get_new_model(model, sample);
            obj.estimator.estimate(new_sample, new_model);
            %Following line is unecessary as the updates happen
            %directly through the class to new_model.setParameters(...)
            %We keep it for now though in case of future changes.
            model.setParameters(new_model.getParameters());
            obj.cputime = toc;
        end
        
        function t = getCPUtime(obj)
            t = obj.cputime;
        end
        
        function residuals = get_residuals(obj, model, sample)
            new_sample = obj.operator.apply(sample);
            new_model = obj.operator.get_new_model(model, sample);
            residuals = obj.estimator.get_residuals(new_model, new_sample);
        end
    end
    
end

