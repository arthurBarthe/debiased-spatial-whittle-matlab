classdef FourierGrid < RectangularGrid
    %This class defines the structure for a Fourier grid. It inherits from
    %the class RectanguarGrid.
    
    properties
        spatial_grid
    end
    
    methods
        function obj = FourierGrid(spatial_grid)
            pi_ = pi;
            assert(isa(spatial_grid, 'RectangularGrid'));
            N = spatial_grid.N;
            M = spatial_grid.M;
            delta_x = spatial_grid.delta_x;
            delta_y = spatial_grid.delta_y;
            if mod(N,2) == 1
                origin_x = - pi_/(delta_x*N)*(N-1);
            else
                origin_x = -pi_/(delta_x);
            end
            if mod(M,2) == 1
                origin_y = - pi_/(delta_x*M)*(M-1);
            else
                origin_y = -pi_/(delta_x);
            end
            obj@RectangularGrid([N M],...
                [2 * pi_ / (delta_x * N)  2 * pi_ / (delta_y * M)], ...
                [origin_x origin_y]);
            obj.spatial_grid = spatial_grid;
        end
        
        function sdf_sample = evaluate_spectral_density(obj, model)
            %Returns the spectral density function of the passed model
            %evaluated at the points of the Fourier grid
            sdf_sample = Sample(obj);
            sdf_sample = SampleOnFourierGrid(sdf_sample);
            sdf_sample.set_values(model.spectral_density(...
                obj.get_points()));
        end
        
        function fftshift(obj)
            %performs the fftshift operation on the grid
            error('not implemented yet');
        end
        
        function ifftshift(obj)
            %performs the ifftshift operation on the grid
            error('not implemented yet');
        end
    end
    
end

