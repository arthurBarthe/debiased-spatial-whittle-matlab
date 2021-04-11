classdef ExponentialModelFamily < IsometricModelFamily
    %This class defines an object representing a family of models based on
    %the exponential covariance model.
    
    properties
    end
    
    methods
        function obj = ExponentialModelFamily(fixed)
            if nargin == 0
                fixed = [false false];
            end
            family_name = 'Exponential covariance family';
            params_names = {'sigma', 'alpha'};
            obj@IsometricModelFamily(family_name, params_names,...
                fixed);
        end
        
        function cov = covariance_isometric(obj, params, distance)
            sigma = params(1);
            alpha = params(2);
            cov = sigma^2*exp(-(distance ./ abs(alpha)));
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
            cov_p(:,:,2) = distance./alpha^2.*cov_p(:,:,2);
        end
        
        function sdf = spectral_density_isometric(obj, params, k)
            sigma = params(1);
            rho = params(2);
            nu = 0.5;
            s = k / (2 * pi);
            sdf = sigma^2 / (4 * pi^2) * 4 * pi * gamma(nu + 1) * ...
                    (2 * nu)^nu / (gamma(nu) * rho^(2 * nu)) * ...
                    (2 * nu / rho^2 + 4 * pi^2 * s.^2).^(-(nu + 1));
        end
    end
    
end

