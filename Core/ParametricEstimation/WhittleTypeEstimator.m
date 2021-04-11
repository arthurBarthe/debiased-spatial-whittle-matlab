classdef WhittleTypeEstimator < LikelihoodEstimator
    %Abstract class for Whittle type estimators, i.e. estimators using the
    %"Whittle distance" and that compute the periodogram. Both the Whittle
    %estimator and the de-biased Whittle estimator inherit this abstract
    %class, by implementing the statistic method differently (spectral
    %density and expected periodogram respectively).
    
    properties
        fit_zero_frequency
        filter_circle
        periodogram
        frequency_grid
    end
    
    methods 
        function obj = WhittleTypeEstimator(name)
            obj@LikelihoodEstimator(name);
            obj.filter_circle = inf;
            obj.fit_zero_frequency = true;
        end
        
        function out = Tbar_(obj, model, sample)
            out = obj.Tbar(model, sample);
            out = out.subsample(obj.frequency_grid);
        end
        
        function T = statistic(obj, sample)
            T = obj.periodogram.compute(sample);
            T = T.subsample(obj.frequency_grid);
        end
        
        function el = compute_expected_likelihood(obj, model, sample, true_model)
            %TODO only work for full grid of frequencies as of now
            el = obj.distance(obj.Tbar(model, sample), ...
                obj.periodogram.compute_expectation(true_model, sample),...
                sample);
        end
        
        function likelihood = distance(obj, Tbar, T, sample)
            %Important to re-scale according to the number of fitted
            %frequencies.
            %TODO change the implementation of the filtering and removing
            %the zero frequency. Slowing down everything rn.
            nb_points = sample.grid.get_nb_points();
            likelihood = 1 / (nb_points) * ...
                sample_sum((sample_log(Tbar) + T ./ Tbar));
        end
        
        function set_fit_zero_frequency(obj, bool)
            bool = logical(bool);
            obj.fit_zero_frequency = bool;
        end
        
        function set_filter_circle(obj, diameter)
            %This function sets a filter for the frequencies used in the
            %fitting procedure. The filter is a circle centered on the zero
            %frequency, with diameter fixed by the user.
            obj.filter_circle = diameter;
        end
        
        function residuals = get_residuals(obj, model, sample)
            %Returns the frequency-domain residuals. 
            T = obj.statistic(sample);
            Tbar = obj.Tbar_(model, sample);
            residuals = - sample_exp(-sample_inv(Tbar) .* T) + 1;
        end
        
        function set_frequency_grid(obj)
            freq_grid = FourierGrid(obj.grid.grid);
            obj.frequency_grid = freq_grid.filter_circle(obj.filter_circle);
            if obj.fit_zero_frequency == false
                %Intersection of the two subgrids
                obj.frequency_grid = obj.frequency_grid .* ...
                    freq_grid.remove_point([0 0]);
            end
            nb = length(obj.frequency_grid.mask);
            %obj.frequency_grid.mask(1 : floor(nb/2)) = 0;
        end
    end
end
