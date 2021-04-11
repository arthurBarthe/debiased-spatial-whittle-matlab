classdef FuentesPeriodogram < Periodogram
    %This class defines the Fuentes periodogram, which replaces missing
    %values with zero and rescales the resulting periodogram by a factor
    %depending on the ratio of the number of observed points to the total
    %number of points of grids.
    
    properties
    end
    
    methods
        function obj = FuentesPeriodogram()
            obj@Periodogram();
        end
        
        function est = compute(obj, sample)
            %This method computes the periodogram proposed by Fuentes.
            %First we replace missing values by zero. Then we we compute
            %the usual periodogram on this new sample. And then we rescale
            %using the number of observed values.
            sample_ = sample.missing_values_to_zero();
            est = compute@Periodogram(obj, sample_);
            h = sample.grid.get_nb_points();
            n = sample_.grid.get_nb_points();
            disp(n/h);
            est = est * (n / h);
        end
        
        function Pbar = compute_expectation_from_kernels(obj, model, ...
                sample, ker1, ker2, cov_mat)
            p = compute_expectation_from_kernels@Periodogram(obj, ...
                model, sample, ker1, ker2, cov_mat);
            h = sample.get_nb_observations();
            n = sample.grid.get_nb_points();
            Pbar = n/h*p;
        end
    end
    
end

