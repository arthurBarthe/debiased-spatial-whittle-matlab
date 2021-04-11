classdef MaternModelFamily < IsometricModelFamily
    %This class implements the Matérn model family, which is an isometric
    %model.
    
    properties
    end
    
    methods
        function obj = MaternModelFamily(fixed)
           if nargin == 0
               fixed = [false false false];
           end
           family_name = 'Matérn family';
           params_names = {'Sigma (Amplitude)', 'nu (Slope)', 'rho (Range)'};
           obj@IsometricModelFamily(family_name, params_names, fixed);
           l_bounds = [0 0.01 0];
           u_bounds = [inf inf inf];
           obj.set_parameters_lower_bound(l_bounds(~fixed));
           obj.set_parameters_upper_bound(u_bounds(~fixed));
        end
        
        function cov = covariance_isometric(obj, params, distance)
            sigma = params(1);
            nu = params(2);
            rho = params(3);
            switch nu
                case 0.5
                    cov = sigma^2 * exp(- distance ./ rho);
                case 3/2
                    cov = sigma^2 * (1 + sqrt(3) * distance / rho) .* ...
                        exp(-sqrt(3) * distance / rho);
                case 5/2
                    cov = sigma^2 * (1 + sqrt(5) * distance / rho + ... 
                        5 * distance.^2  / (3 * rho^2)) .* ...
                        exp(-sqrt(5) * distance / rho);
                case inf
                    %This is the squared exponential family
                    cov = sigma^2 * exp(-0.5 * (distance / rho).^2);
                otherwise 
                    %This is the general expression, which requires
                    %evaluation of the modified Bessel function.
                    cov = sigma^2 / (2^(nu-1)*gamma(nu)) * ...
                        (sqrt(2*nu)*distance/rho).^nu .* ...
                        besselk(nu, sqrt(2*nu) * distance/rho);
                    cov(distance == 0) = sigma^2;
            end
        end
        
        function cov_p = covariance_prime_isometric(obj, params, distance)
            sigma = params(1);
            nu = params(2);
            rho = params(3);
            %This method returns the derivative of the covariance function
            %with respect to the parameter vector, evaluated at the passed
            %values for the parameters and for the distance.
            if nu == 0.5
                cov_p = obj.covariance_isometric(params, distance);
                cov_p = repmat(cov_p, 1, 1, 2);
                cov_p(:,:,1) = 2*cov_p(:,:,1)/sigma;
                cov_p(:,:,2) = distance./rho^2.*cov_p(:,:,2);
            end
        end
        
        function sdf = spectral_density_isometric(obj, params, k)
            sigma = params(1);
            nu = params(2);
            rho = params(3);
            s = k/ (2 * pi);
            if nu ~= inf
                sdf = sigma^2 / (4 * pi^2) * 4 * pi * gamma(nu + 1) * ...
                    (2 * nu)^nu / (gamma(nu) * rho^(2 * nu)) * ...
                    (2 * nu / rho^2 + 4 * pi^2 * s.^2).^(-(nu + 1));
            else
                sdf = 1/(4*pi^2)*sigma^2*2*pi*rho^2*exp(-2*pi^2*rho^2*s.^2);
            end
        end
    end
    
    methods (Access = protected)
        function text = value_to_text(obj, i, value, sample)
            switch i
                case 3
                    %TODO
                    grid = sample.grid.grid;
                    max_N_M = max(grid.N, grid.M); 
                    percentage = value / max_N_M * 100;
                    nb_steps = value / grid.delta_x;
                    text = [num2str(percentage) '% of grid diameter / '...
                        num2str(nb_steps) ' steps'];
                otherwise
                    text = value_to_text@ModelFamily(obj, i, value, sample);
            end
        end
    end
    
end

