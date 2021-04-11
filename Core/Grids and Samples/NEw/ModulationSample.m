classdef ModulationSample < SampleOnRectangularGrid
    %This class is used to represent modulation samples. In particular,
    %this class defines methods used for the computation of the expected
    %periodogram, that will account for the modulation on the sample.
    
    properties
        kernel1
        kernel2
    end
    
    methods
        function obj = ModulationSample(rect_grid)
            assert(isa(rect_grid, 'RectangularGrid'));
            obj@SampleOnRectangularGrid(Sample(rect_grid));
        end
        
        function set_values(obj, values)
            set_values@SampleOnRectangularGrid(obj, values);
            obj.update_kernels();
        end
        
        function [kernel1, kernel2] = get_kernels(obj)
            %Returns the kernels corresponding to the modulation sample.
            %These are used for the computation of the expected
            %periodogram.
            kernel1 = obj.kernel1;
            kernel2 = obj.kernel2;
        end
        
        function update_kernels(obj)
            %Returns the two kernels used in the computation of the
            %expected periodogram.
            rect_grid = obj.grid;
            N = rect_grid.N;
            M = rect_grid.M;
            g = obj.get_values_matrix();
            %In the general case we must use FFTs.
            f = 1/(N*M)*abs(fft2(g,2*N,2*M)).^2;
            ker1 = ifft2(f);
            obj.kernel1 = ker1(1:N,1:M);
            g = fliplr(g);
            f = 1/(N*M)*abs(fft2(g,2*N,2*M)).^2;
            ker2 = ifft2(f);
            obj.kernel2 = ker2(1:N,1:M);
        end
    end
    
end

