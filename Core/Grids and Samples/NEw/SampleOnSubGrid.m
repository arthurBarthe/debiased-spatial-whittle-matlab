classdef SampleOnSubGrid < Sample
    %This class inherits from the Sample class and defines the structure
    %for a sample on a SubGrid. 
    
    properties
    end
    
    methods
        function obj = SampleOnSubGrid(sample)
            obj@Sample(sample.grid);
            obj.set_values(sample.values);
        end
        
        function sample = new(obj)
            sample = SampleOnSubGrid(new@Sample(obj));
        end
        
        function sample = missing_values_to_zero(obj)
            %Returns a Sample object on the base grid where missing values
            %have been replaces by zeros
            base_grid = obj.grid.grid;
            sample = Sample(base_grid);
            nb_points = base_grid.get_nb_points();
            full_values = zeros(nb_points, 1);
            full_values(obj.grid.mask) = obj.values;
            sample.set_values(full_values);
        end
        
        function h = plot(obj, varargin)
            %In plotting a sample on a subgrid, we replace missing points
            %by zeros to obtain a full sample and plot that sample.
            s = obj.missing_values_to_zero();
            h = s.plot(varargin{1:end});
        end
        
        %Operators overloading---------------------------------------------
        function sample = plus(sample1, sample2)
            sample_temp = plus@Sample(sample1, sample2);
            sample = SampleOnSubGrid(sample_temp);
        end
        
        function sample = minus(sample1, sample2)
            sample_temp = minus@Sample(sample1, sample2);
            sample = SampleOnSubGrid(sample_temp);
        end
        
        function sample = uminus(obj)
            sample_temp = uminus@Sample(obj);
            sample = SampleOnSubGrid(sample_temp);
        end
        
        function sample = times(sample1, sample2)
            sample_temp = times@Sample(sample1, sample2);
            sample = SampleOnSubGrid(sample_temp);
        end
        
        function sample = mtimes(sample1, scalar_value)
            sample_temp = mtimes@Sample(sample1, scalar_value);
            sample = SampleOnSubGrid(sample_temp);
        end
        
        function sample = rdivide(sample1, sample2)
            sample_temp = rdivide@Sample(sample1, sample2);
            sample = SampleOnSubGrid(sample_temp);
        end
        
        function sample = mrdivide(sample1, scalar_value)
            sample_temp = mrdivide@Sample(sample1, scalar_value);
            sample = SampleOnSubGrid(sample_temp);
        end
        
    end
end

