classdef FuentesWhittle < Whittle
    %Implements the estimator proposed by Fuentes that adapts the Whittle
    %estimation to missing data.
    
    properties
    end
    
    methods
        function obj=FuentesWhittle()
            obj@Whittle();
        end
        
        function T = statistic(obj, sample)
            T = obj.periodogram.compute(sample);
            T = T.subsample(obj.frequency_grid);
            grid = sample.grid;
            grid_complete = grid.get_complete_grid();
            ratio = grid_complete.get_nb_points() / grid.get_nb_points();
            T = T *ratio;
        end
    end
end

