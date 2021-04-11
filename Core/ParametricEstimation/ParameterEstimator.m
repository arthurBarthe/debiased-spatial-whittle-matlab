classdef ParameterEstimator < handle
    %Abstract class for any parameter estimator. 
    %
    %In particular this defines the signature of the function estimate. 
    %All estimators must also be given a name, so that when a comparison of
    %two estimators is carried out, they can be distinguished in the
    %results summary or graphics produced.
    %Properties
    %name: string, name of the parameter estimator. This is useful when
    %comparing several estimators, in order to distinguish them.
    %grid: Grid, the grid the estimator works on. 
    %TODO we should check that the sample passed to estimate is defined on
    %the same grid as that of the parameter estimator.
    
    properties
        name
        grid
    end
    
    methods (Abstract)
       estimate(obj, sample, model); 
       t = getCPUtime(obj)
       residuals = get_residuals(obj, model, sample)
    end
    
    methods
        function obj = ParameterEstimator(name, grid)
            obj.name = name;
        end
        
        function n = getName(obj)
            n = obj.name;
        end
        
        function setName(obj, n)
            obj.name = n;
        end
        
        function s = toString(obj)
            s = ['Estimator name: ' obj.name];
        end
        
        function plot_residuals(obj, model, sample)
            residuals_sample = obj.get_residuals(model, sample);
            figure
            subplot(121)
            residuals_sample.plot(0, 'Residuals');
            subplot(122)
            histogram(residuals_sample.get_values(), 'binwidth', 0.1);
            title('Residuals distribution');
            suptitle(['Residuals for ' obj.name]);
        end
    end
    
end

