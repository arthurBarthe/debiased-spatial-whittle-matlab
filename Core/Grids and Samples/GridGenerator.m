classdef GridGenerator < handle
    %This interface defines the structure of an object that is used to
    %generate grids. Such generators can then be used by some tests.
    
    properties
    end
    
    methods (Abstract)
        grid = generate_grid(obj);
    end
end

