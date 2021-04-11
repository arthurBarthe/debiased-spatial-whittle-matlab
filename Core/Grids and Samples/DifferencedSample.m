classdef DifferencedSample < Sample
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sample
    end
    
    methods
        function obj = DifferencedSample(sample)
            grid = sample.grid;
            new_grid = RectangularGrid(grid.N - 1, grid.M - 1, ...
                grid.delta_x, grid.delta_y);
            mask = grid.values_to_matrix_form(sample.mask);
            new_mask = mask(1:end-1, 1:end-1);
            new_mask = new_mask(:);
            obj@Sample(new_grid, new_mask);
            obj.sample = sample;
        end
        
        function simulated_sample =  simulate(obj, model, generator)
            differencing_operator = DifferencingOperator();
            simulated_sample = differencing_operator.apply(...
                obj.sample.simulate(model.model, generator));
        end
    end
    
end

