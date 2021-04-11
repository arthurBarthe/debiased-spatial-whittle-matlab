classdef DiscreteModel1 < ModelFamily
    %This class implements the Matérn model family, which is an isometric
    %model.
    
    properties
    end
    
    methods
        function obj = DiscreteModel1(fixed)
           if nargin == 0
               fixed = [false false];
           end
           family_name = 'Discrete Model 1';
           params_names = {'sigma', 'theta_x'};
           obj@ModelFamily(family_name, params_names, fixed);
           l_bounds = [0 0 0];
           u_bounds = [inf inf inf];
           obj.set_parameters_lower_bound(l_bounds(~fixed));
           obj.set_parameters_upper_bound(u_bounds(~fixed));
        end
    end
    
    methods(Access = protected)    
        function cov = covariance_(obj, params, lag_X, lag_Y)
            sigma = params(1);
            theta_x = params(2);
            theta_y = theta_x;
            cov_x = 1 / pi * real(1 ./ (1i * lag_X - theta_x) .* ...
                (exp((1i * lag_X - theta_x) * pi) - 1));
            cov_y = 1 / pi * real(1 ./ (1i * lag_Y - theta_y) .* ...
                (exp((1i * lag_Y - theta_y) * pi) - 1));
            cov = sigma^2 * cov_x .* cov_y;
        end
        
        function sdf = spectral_density_(obj, params, freq_x, freq_y)
            sigma = params(1);
            theta_x = params(2);
            theta_y = theta_x;
            % Some issue, had to inverse y and x
            sdf_x = exp(-theta_x * abs(freq_x));
            sdf_y = exp(-theta_y * abs(freq_y));
            sdf = sdf_x .* sdf_y;
            sdf = sigma^2 * sdf / (2 * pi)^2;
        end
        
        function cov_p = covariance_prime_(obj, params, distance)
            disp('not implemented');
        end
    end
    
end

