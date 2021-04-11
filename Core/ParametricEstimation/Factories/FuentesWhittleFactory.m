classdef FuentesWhittleFactory < ParameterEstimatorFactory
    properties
        sum_truncation
    end
    
    methods
        function obj = FuentesWhittleFactory(sum_truncation)
            switch nargin
                case 0
                    obj.sum_truncation = 1;
                case 1
                    obj.sum_truncation = sum_truncation;
            end
        end
        
        function estimator = get_estimator(obj, grid, choice)
            estimator = FuentesWhittle();
            estimator.grid = grid;
            estimator.sum_truncation = obj.sum_truncation;
        end
    end
end
