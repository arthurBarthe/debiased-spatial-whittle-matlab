classdef Whittle < WhittleTypeEstimator
    %This class represents the classical Whittle estimator.
    %Note that the user must specify an estimator of the spectral density.
    %This could be the normal periodogram or a tapered version, etc.
    %To add: include the possibility to add the range of frequencies to be
    %included in the fitting procedure.
    %Properties:
    %sum_truncation: int, number of terms included in the computation of
    %the aliased spectrum
    
    properties
        sum_truncation
    end
    
    methods
        function obj=Whittle()
            obj@WhittleTypeEstimator('Whittle');
            obj.sum_truncation = 1;
        end
        
        function Tbar = Tbar(obj, model, sample)
            %The fitted quantity in the case of the Whittle likelihood is
            %the spectral density on the grid of Fourier frequencies that
            %corresponds to the grid of the sample, or possibly an
            %approximation of the alisased spectral density.
            grid = sample.grid;
            rect_grid = grid.grid;
            if obj.sum_truncation == 1
                Tbar = model.spectral_density_on_grid(rect_grid);
            else
                Tbar = model.aliased_spectral_density(rect_grid, ...
                    obj.sum_truncation);
            end
        end
    end

end



