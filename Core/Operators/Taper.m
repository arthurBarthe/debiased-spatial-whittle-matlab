classdef Taper < ModulationOperator
    %UNTITLED25 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        taper_function  %A function handle used for tapering
    end
    
    methods
        function obj = Taper(taper_function, name)
            obj@ModulationOperator(name);
            obj.taper_function = taper_function;
        end

        function values = compute_modulation_values(obj, rect_grid)
            N = rect_grid.N;
            M = rect_grid.M;
            values = obj.taper_function(N)*obj.taper_function(M)';
            %We normalise. Remember that the usual periodogram divides by
            %(N*M) so the taper values should normalise to N*M just like
            %when they take value 1 everywhere.
            values = sqrt(N*M)*(sum(sum(values.^2)))^(-1/2)*values;
            %Following line needs to be modified to not depend on the
            %ordering of points of the grid.
            values = values(:);
        end
    end
end

