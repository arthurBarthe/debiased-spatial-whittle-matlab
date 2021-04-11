classdef ExponentialSmootherOperator < SampleOperator
    %This class defines the structure for defining smoother operators. One
    %can adjust the smoothing parameter in each direction.
    
    properties
        smoothing_parameter
    end
    
    methods
        function obj = ExponentialSmootherOperator(p1, p2)
            obj@SampleOperator('Exponential smoothing operator');
            obj.smoothing_parameter = [p1 p2];
        end
    end
    
    methods (Access = protected)
        function new_sample = apply_(obj, sample)
            %First we apply the smoothing along the first dimension
            grid = sample.grid;
            values_mat = grid.values_to_matrix_form(sample.values);
            smoothed = smoothdata(values_mat, 'movmedian', ...
                obj.smoothing_parameter(1));
            smoothed = smoothdata(smoothed', 'movmedian', ...
                obj.smoothing_parameter(2));
            smoothed = smoothed';
            sample = Sample(grid);
            new_sample = ValuedSample(sample, smoothed(:));
        end
    end
    
end

