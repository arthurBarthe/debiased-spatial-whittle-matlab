classdef WhittleTypeEstimatorFactory < ParameterEstimatorFactory
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fit_zero_frequency
        circle_diameter
        periodogram
    end
    
    methods
        function obj = WhittleTypeEstimatorFactory(periodogram,...
                fit_zero_frequency, diameter)
            switch nargin
                case 0
                    periodogram = Periodogram();
                    fit_zero_frequency = true;
                    diameter = inf;
                case 1
                    fit_zero_frequency = true;
                    diameter = inf;
                case 2
                    diameter = inf;
            end
            obj.fit_zero_frequency = fit_zero_frequency;
            obj.circle_diameter = diameter;
            obj.periodogram = periodogram;
        end
        
        function estimator = get_estimator(obj, grid, choice)
            estimator = get_estimator@ParameterEstimatorFactory(obj, ...
                grid, choice);
            estimator.set_filter_circle(obj.circle_diameter);
            estimator.set_fit_zero_frequency(obj.fit_zero_frequency);
            estimator.set_frequency_grid();
            estimator.periodogram = obj.periodogram;
        end
    end
    
end

