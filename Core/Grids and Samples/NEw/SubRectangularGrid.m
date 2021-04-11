classdef SubRectangularGrid < SubGrid
    %This class inherits from SubGrid and defines the particular case of a
    %SubGrid whose base grid is Rectangular. It defines a Fejer kernel
    %methods which accounts for the missing points.
    
    properties
        modulation_sample
    end
    
    methods
        function obj = SubRectangularGrid(varargin)
            obj@SubGrid(varargin{:});
        end
        
        function kernel = get_fejer_kernel(obj, density)
            %Returns the "modified" Fejer kernel, where missing points are
            %replaced by zeros (see article)
            %TODO add equation reference once article submitted
            data = reshape(obj.mask, obj.grid.N, obj.grid.M);
            kernel = fft2(data, density * obj.grid.shape(1), ...
                density * obj.grid.shape(2));
            kernel = 1 / obj.grid.get_nb_points() * abs(kernel) .^ 2;
            kernel = fftshift(kernel);
        end
        
        function plot_fejer_kernel(obj, density)
            %Plots the "modified" Fejer kernel, where missing points are
            %replaced by zeros.
            switch nargin
                case 1
                    density = 10;
            end
            kernel = obj.get_fejer_kernel(density);
            figure();
            title('Fejer kernel');
            imagesc(10 * log10(kernel));
            colorbar
        end
        
        function mask = get_mask_new(obj)
            mask = obj.modulation_sample;
        end
        
        function set_mask(obj, mask)
            set_mask@SubGrid(obj, mask);
            obj.modulation_sample = ModulationSample(obj.grid);
            obj.modulation_sample.set_values(mask);
        end
        
        function sdf_sample = spectral_density(obj, model)
            %Returns a FourierSample of the spectral density evaluated on
            %the rectangular grid associated with the object.
            rect_grid = obj.grid;
            fourier_grid = rect_grid.fourier_grid();
            sdf_sample = fourier_grid.evaluate_spectral_density(model);
        end
    end
end

