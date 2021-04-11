classdef ExactLikelihood < LikelihoodEstimator
    %This class defines the exact likelihood estimator.
    
    properties
    end
    
    methods
        function obj = ExactLikelihood()
            obj@LikelihoodEstimator('Exact likelihood')
        end
        
        function T = statistic(obj, sample)
            T = sample.get_values();
        end
        
        function Tbar = Tbar(obj, model, sample)
            Tbar = model.covariances_on_grid(sample.grid);
        end
        
        function likelihood = distance(obj, Tbar, T, sample)
            %Code by Adam Sykulski
            try
                L = chol(Tbar); % Cholesky for determinant and inverse
            catch e
                likelihood = 999999999;
                disp(['Cholesky decomposition not achieved during ' ...
                    'exact likelihood']);
                disp(['Error message: ' e.message]);
                return
            end
            logdetC = 2*sum(log(diag(L))); % log-determinant
            likelihood=0.5*logdetC+0.5*(T'/L)*(L'\T); % log-likelihood
        end
        
        function initialize_estimation_(obj, sample)
            return
        end
        
        function residuals = get_residuals(obj, model, sample)
            T = obj.statistic(sample);
            Tbar = obj.Tbar(model, sample);
            %The following quantity should ideally be white noise like.
            L = chol(T);
            whitened = L'\T;
            mu = 0;
            sigma = 1;
            normal_distr = makedist('Normal',mu,sigma);
            %We compose by the cdf of the standard normal distribution,
            %which ideally should lead to a uniform distribution on [0,1].
            residuals = cdf(normal_distr, whitened);
        end
    end
    
end

