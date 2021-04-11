classdef BiasPlusNoiseEstimator < ParameterEstimator
    %This class represents a fictive estimator used principally to
    %initialize likelihood methods in simulations.
    %
    %It is fictive since it uses the true parameter values to produce an
    %estimate. It adds a bias and some noise.
    %
    %Properties:
    %   bias_amount:    double, positive. 0 means no bias, 1 means 100%
    %       bias.
    %   noise_amount:   double, positive. 0 means no added noise, 1 means
    %       std of noise is the value of the parameter.
    %   true_model:     Model, the true model to be estimated.
    
    properties (Access = private)
        bias_amount
        noise_amount
        true_model
    end
    
    methods
        function obj = BiasPlusNoiseEstimator()
            obj@ParameterEstimator('Bias+NoiseEstimator');
        end
        
        function estimate(obj, sample, model)
            %This methods estimates the model given the sample. It does not
            %return any value but updates the parameters of the passed
            %model directly.
            %Args:
            %   sample:     ValuedSample, the data used for estimation.
            %   model:      Model, the model to be estimated.
            %Returns:
            %   None
            assert(obj.true_model);
            assert(obj.bias_amount);
            assert(obj.noise_amount);
            true_params = obj.true_model.getParameters();
            nb_params = length(true_params);
            bias = obj.bias_amount;
            noise = obj.noise_amount .* randn(nb_params, 1);
            estimates = true_params .* (1 + bias + noise);
            model.setParameters(estimates);
        end
    end
    
end

