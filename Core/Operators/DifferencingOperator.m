classdef DifferencingOperator < SampleOperator
    %This class defines the differencing operation. 
    
    properties
    end
    
    methods
        function obj = DifferencingOperator()
            obj@SampleOperator('Differencing operator');
        end
        
        function new_model = get_new_model(~, model, sample)
            new_model = DifferencedModel(model);
        end
    end
    
    methods (Access = protected)
        function new_sample = apply_(obj, sample)
            sample = sample.missing_values_to_zero();
            grid = sample.grid;
            values_matrix = grid.values_to_matrix_form(sample.get_values());
            new_values_matrix = 0.5 * values_matrix(2 : end, 1 : end - 1)...
                + 0.5 * values_matrix(1 : end - 1, 2 : end) ...
                - values_matrix(1 : end - 1, 1 : end - 1);
            new_grid = RectangularGrid([grid.N - 1, grid.M - 1], ...
                [grid.delta_x, grid.delta_y]);
            new_grid = SubGrid(new_grid);
            new_sample = Sample(new_grid);
            new_sample = SampleOnSubGrid(new_sample);
            new_sample.set_values(new_values_matrix(:));
        end
    end
end

