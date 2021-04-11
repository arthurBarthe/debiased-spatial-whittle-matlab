classdef SampleOnRectangularGrid < SampleOnSubGrid
    %This class inherits from the Sample class, and represents the
    %situation where the sample is on a RectangularGrid.
    
    properties
    end
    
    methods
        function obj = SampleOnRectangularGrid(sample)
            obj@SampleOnSubGrid(sample);
            obj.set_values(sample.values);
        end
        
        function values = get_values_matrix(obj)
            values = obj.get_values();
            values = obj.grid.values_to_matrix_form(values);
        end
        
        function sample = missing_values_to_zero(obj)
            %Returns a Sample object on the base grid where missing values
            %have been replaces by zeros
            sample = missing_values_to_zero@SampleOnSubGrid(obj);
            sample = SampleOnRectangularGrid(sample);
        end
    end
end

