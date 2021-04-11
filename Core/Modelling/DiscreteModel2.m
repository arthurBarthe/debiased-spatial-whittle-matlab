classdef DiscreteModel2 < ModelFamily
    %This class implements the Matérn model family, which is an isometric
    %model.
    
    properties
    end
    
    methods
        function obj = DiscreteModel2(fixed)
           if nargin == 0
               fixed = [false false];
           end
           family_name = 'Discrete Model 1';
           params_names = {'sigma', 'theta'};
           obj@ModelFamily(family_name, params_names, fixed);
           l_bounds = [0 0];
           u_bounds = [inf inf];
           obj.set_parameters_lower_bound(l_bounds(~fixed));
           obj.set_parameters_upper_bound(u_bounds(~fixed));
        end
    end
    
    methods(Access = protected)    
        function cov = covariance_(obj, params, lag_X, lag_Y)
            sigma = params(1);
            theta = params(2);
            xs = unique(lag_X);
            ys = unique(lag_Y);
            xs_ = arrayfun(@(n)integral(@(x)exp(-theta*x.^2 + 1i * n * x), -pi, pi), xs);
            ys_ = arrayfun(@(n)integral(@(x)exp(-theta*x.^2 + 1i * n * x), -pi, pi), ys);
            cov_x = zeros(size(lag_X));
            for j = 1 : length(xs)
                cov_x (lag_X == xs(j)) = real(xs_(j));
            end
            cov_y = zeros(size(lag_X));
            for j = 1 : length(xs)
                cov_y (lag_Y == ys(j)) = real(ys_(j));
            end
            cov = sigma^2 * cov_x .* cov_y;
        end
        
        function sdf = spectral_density_(obj, params, freq_x, freq_y)
            sigma = params(1);
            theta = params(2);
            sdf_x = exp(-theta * abs(freq_x));
            sdf_y = exp(-theta * abs(freq_y));
            sdf = sdf_x .* sdf_y;
            sdf = sigma^2 * 2 / theta * sdf / (2 * pi)^2;
        end
        
        function cov_p = covariance_prime_(obj, params, distance)
            disp('not implemented');
        end
    end
    
end

