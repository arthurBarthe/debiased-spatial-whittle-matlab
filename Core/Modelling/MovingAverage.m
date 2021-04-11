classdef MovingAverage < ModelFamily
    %This class implements the Matérn model family, which is an isometric
    %model.
    
    properties
    end
    
    methods
        function obj = MovingAverage(fixed)
           if nargin == 0
               fixed = [false];
           end
           family_name = 'Moving Average';
           params_names = {'theta'};
           obj@ModelFamily(family_name, params_names, fixed);
           l_bounds = [0];
           u_bounds = [0.25];
           obj.set_parameters_lower_bound(l_bounds(~fixed));
           obj.set_parameters_upper_bound(u_bounds(~fixed));
        end
    end
    
    methods(Access = protected)    
        function cov = covariance_(obj, params, lag_X, lag_Y)
            theta = params(1);
            distance = abs(lag_X+1i*lag_Y);
            cov = zeros(size(distance));
            K = (1 + 4 * theta^2);
            cov(distance == 0) = 1;
            cov(distance == 1) = 2 * theta / K;
            cov(distance == 2) = theta^2 / K;   
            cov(distance == sqrt(2)) = 2 * theta^2 / K;
        end
        
        function sdf = spectral_density_(obj, params, freq_x, freq_y)
            theta = params(1);
            sdf = abs(1 + theta * (exp(1i * freq_x) + exp(-1i * freq_x)...
                + exp(1i * freq_y) + exp(-1i * freq_y))).^2;
            sdf = sdf / (2 * pi)^2;
        end
        
        function cov_p = covariance_prime_(obj, params, distance)
            disp('not implemented');
        end
    end
    
end

