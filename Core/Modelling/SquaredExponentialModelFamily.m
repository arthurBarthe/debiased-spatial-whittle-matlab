classdef SquaredExponentialModelFamily < IsometricModelFamily
    %UNTITLED16 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = SquaredExponentialModelFamily(fixed)
            if nargin == 0
                fixed = [false false];
            end
            family_name = 'SquaredExponential';
            params_names = {'sigma', 'alpha'};
            obj@IsometricModelFamily(family_name, params_names,...
                fixed);
        end
        
        function cov = covariance_isometric(obj, params, distance)
            sigma = params(1);
            alpha = params(2);
            cov = sigma^2*exp(-(distance/alpha).^2);
        end
        
        function cov_p = covariance_prime_isometric(obj, params, distance)
            %This method returns the derivative of the covariance function
            %with respect to the parameter vector, evaluated at the passed
            %values for the parameters and for the distance.
            sigma = params(1);
            alpha = params(2);
            cov_p = obj.covariance_isometric(params, distance);
            cov_p = repmat(cov_p, 1, 1, 2);
            cov_p(:,:,1) = 2*cov_p(:,:,1)/sigma;
            cov_p(:,:,2) = 2/alpha^3.*distance.^2.*cov_p(:,:,2);
        end
        
        function sdf = spectral_density_isometric(obj, params, k)
            sigma = params(1);
            alpha = params(2);
            s = k/(2*pi);
            l = alpha / sqrt(2);
            sdf = 1/(4*pi^2)*sigma^2*2*pi*l^2*exp(-2*pi^2*l^2*s.^2);
        end
    end
    
end

