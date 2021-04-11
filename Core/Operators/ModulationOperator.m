classdef ModulationOperator < SampleOperator
    %This class represents operators which act pointwise on a grid by
    %applying a pointwise multiplication.
    
    properties
        last_rect_grid
        last_values
    end
    
    methods (Abstract)
        values = compute_modulation_values(grid)
    end
    
    methods 
        function obj = ModulationOperator(name)
            obj@SampleOperator(name);
        end
        
        function mod_sample = get_modulation_sample(obj, sample)
            %sample: SampleOnSubGrid, the subgrid of that sample should be
            %a SubRectangularGrid.
            rect_grid = sample.grid.grid;
            rect_sample = Sample(rect_grid);
            rect_sample.set_values(obj.get_modulation_values(rect_grid));
            mod_sample = rect_sample.subsample(sample.grid);
        end
            
        
        function values = get_modulation_values(obj, rect_grid)
            %If the grid of the sample if the same as for the last call, we
            %use the stored values and avoid re-computing them.
            if rect_grid == obj.last_rect_grid
                values = obj.last_values;
            else
                values = obj.compute_modulation_values(rect_grid);
                obj.last_rect_grid = rect_grid;
                obj.last_values = values;
            end
        end
        
        function plot(obj, sample)
            mod_sample = obj.get_modulation_sample(sample);
            mod_sample.plot();
        end
    end
    
    methods (Access = protected)
        function sample_new = apply_(obj, sample)
            taper_sample = obj.get_modulation_sample(sample);
            sample_new = sample .* taper_sample;
        end
    end
end

