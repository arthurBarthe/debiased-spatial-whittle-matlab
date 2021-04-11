classdef ParameterEstimatorFactory < handle
    %This class is a singleton that defines a factory to create instances
    %of concrete objects defined on the interface ParameterEstimator.
    properties
        subfactories
    end
    
    methods
        function obj = ParameterEstimatorFactory()
            obj.subfactories = containers.Map;
        end
        
        function add_sub_factory(obj, name, factory)
            obj.subfactories(name) = factory;
        end
        
        function estimator = get_estimator(obj, grid, choice)
            subfactory = obj.subfactories(choice);
            estimator = subfactory.get_estimator(grid, ...
                choice);
        end
    end
end