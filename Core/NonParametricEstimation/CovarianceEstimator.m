classdef CovarianceEstimator < Estimator
    %This class estimates the homogeneous covariance matrix for a
    %rectangular sample, using the FFT.
    
    properties
    end
    
    methods
        function obj = CovarianceEstimator()
            obj@Estimator('Sample covariance estimator');
        end
        
        function est = compute(obj, valued_sample)
            grid = valued_sample.grid;
            values = valued_sample.get_values();
            values = grid.values_to_matrix_form(values);
            N = grid.N;
            M = grid.M;
            f = 1/(N*M)*abs(fft2(values,2*N,2*M)).^2;
            cov1 = ifft2(f);
            cov1 = cov1(1:N,1:M);
            values = fliplr(values);
            f = 1/(N*M)*abs(fft2(values,2*N,2*M)).^2;
            cov2 = ifft2(f);
            cov2 = cov2(1:N,1:M);
            cov2 = fliplr(cov2);
            est = [flip([cov2(:,1:end-1) cov1]); cov2(:,1:end-1) cov1];
        end
    end
    
end

