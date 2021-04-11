classdef IsometricModelFamily < ModelFamily
    %This class defines the representation of an Isometric Model Family.
    %
    %In particular it makes use of isometry to define its autocovariance 
    %and spectral density functions.
    
    properties
    end
    
    methods (Abstract)
        cov = covariance_isometric(obj, params, distance)
        sdf = spectral_density_isometric(obj, params, frequency_norm)
        cov_p = covariance_prime_isometric(obj, params, distance)
    end
    
    methods
        function obj = IsometricModelFamily(name, parameters_names, fixed)
            obj@ModelFamily(name, parameters_names, fixed);
        end
    end
    
    methods (Access = protected)
        function cov = covariance_(obj, parameters, lag_X, lag_Y)
            distance = abs(lag_X+1i*lag_Y);
            cov = obj.covariance_isometric(parameters, distance);
        end
        
        function cov_p = covariance_prime_(obj, parameters, lag_X, lag_Y)
            distance = abs(lag_X+1i*lag_Y);
            cov_p = obj.covariance_prime_isometric(parameters, distance);
        end
        
        function sdf = spectral_density_(obj, params,  freq_X, freq_Y)
            distance = abs(freq_X+1i*freq_Y);
            sdf = obj.spectral_density_isometric(params, distance);
        end
    end
end

