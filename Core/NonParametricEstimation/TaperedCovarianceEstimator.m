classdef TaperedCovarianceEstimator < CovarianceEstimator
    %This class estimates a covariance-tapered version of the covariance
    %matrix.
    
    properties
        gamma
    end
    
    methods
        function obj = TaperedCovarianceEstimator(gamma)
            obj@CovarianceEstimator();
            obj.gamma = gamma;
        end
        
        function est = compute(obj, sample)
            est = compute@CovarianceEstimator(obj, sample);
            taper = obj.getCovarianceTaper(sample);
            est = taper .* est;
        end
        
        function taper = getCovarianceTaper(obj, sample)
            grid = sample.grid;
            taper = grid.getCovarianceMatrixTaper(obj.gamma);
        end
            
    end
    
end

