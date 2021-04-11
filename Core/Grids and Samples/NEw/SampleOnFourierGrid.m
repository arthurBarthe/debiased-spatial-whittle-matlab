classdef SampleOnFourierGrid < SampleOnRectangularGrid
    %This class defines the structure for frequency-domain samples. In
    %particular, any call of the plot method will imply plotting the log of
    %the sample rather than the values, unless specified otherwise.
    properties
    end
    
    methods
        function obj = SampleOnFourierGrid(sample)
            obj@SampleOnRectangularGrid(sample);
        end
        
        function h = plot(obj, varargin)
            log_values = 10*log10(obj.values);
            h = obj.grid.plot_values_on_grid(log_values, varargin{1:end});
        end
    end
end

