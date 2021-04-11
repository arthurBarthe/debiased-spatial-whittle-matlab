classdef Model < handle
    %This class defines the representation of a model, as a particular
    %member of a model family.
    %
    %More precisely, a Model instance is defined by both a ModelFamily
    %instance and a set of parameters.
    %
    %Attributes:
    %   model_family:   ModelFamily, the model family the model belongs to.
    %   parameters:     Double[px1], a vector of parameter values
    %       corresponding to the parameters of the model family which are
    %       not fixed.
    
    properties
        parameters
        model_family
    end
     
    %Constructor and parameter methods---------------------------------
    methods
        function obj = Model(parameters, model_family)
            switch nargin
                case 1
                    assert(isa(parameters, 'ModelFamily'));
                    obj.model_family = parameters;
                case 2
                    obj.parameters = parameters;
                    obj.model_family = model_family;
            end
        end
        
        function setParameters(obj, parameters)
            %Sets the parameters of the model. Note that only non-fixed
            %parameters of the model family can be changed (non-fixed as
            %defined in the model family). 
            %Args
            %parameters [1xp] the parameter vector
            if ~isrow(parameters)
                error('Parameters should be a row vector.')
            end
            nb_params = obj.model_family.get_nb_parameters();
            if length(parameters) ~= nb_params
                message = ['The number of passed parameters should be ' ...
                    num2str(nb_params)];
                error(message);
            end
            %We use the model family function that ensures the parameters
            %stay within the bounds.
            obj.parameters = obj.model_family.ensure_parameters_bounds(...
                parameters);
        end
        
        function params = getParameters(obj)
            %Returns the parameter vector of the model. Ignores parameters
            %of the model family that are fixed.
            if isempty(obj.parameters)
                error('The parameters of this model have not been fixed.');
            else
                params = obj.parameters;
            end
        end
        
        function n = getNbParams(obj)
            %Returns the number of parameters of the model. Ignores
            %parameters of the model family that are fixed.
            n = length(obj.parameters);
        end
        
        function display_parameters(obj, sample)
            %Displays the parameters of the model. A sample is required as
            %some parameters, such as the range, might be expressed
            %relatively to the grid size/step etc.
            nb_parameters = obj.getNbParams();
            m_fam = obj.model_family;
%             disp(['Model family: ' m_fam.model_family_name]);
            for i = 1 : nb_parameters
                m_fam.display_parameter(i, obj.parameters(i), sample);
            end
        end
        
        function name = getParameterName(obj, i)
            name = obj.model_family.get_parameter_name(i);
        end
        
        function params = get_full_parameters(obj)
            %Returns the full parameter vector of the model, i.e. including
            %those that are fixed in the model family.
            params = obj.model_family.full_parameter_vector(obj.parameters);
        end
        
        function fix_parameters(obj, fixed)
            %Fixes some parameters of the model. A new model family is
            %created and the model's family is changed to that family.
            new_model_family = obj.model_family.fix_parameters(obj, fixed);
            obj.parameters = obj.parameters(~fixed);
            obj.model_family = new_model_family;
        end
    end
    
    %Second-order methods ---------------------------------------------
    methods
        function cov = covariance_func(obj, lag_X, lag_Y)
            %Returns the model's covariance for the passed lags.
            cov = obj.model_family.covariance(obj.parameters, lag_X, lag_Y);
        end
        
        function sdf = spectral_density(obj, frequencies)
            sdf = obj.model_family.spectral_density(obj.parameters, ...
                frequencies(:,1), frequencies(:,2));
        end 
        
        function cov_p = covariance_prime(obj, lag_X, lag_Y)
            %This method returns the vector of derivatives of the
            %covariance function with respect to the parameter vector of
            %the model, evaluated at lag (lag_X, lag_Y)
            cov_p = obj.model_family.covariance_prime(obj.parameters, ...
                lag_X, lag_Y);
        end
        
        %Grid specific methods --------------------------------------------
        
        function cov_mat = covariances_on_grid(obj, grid)
            %This function returns a matrix of the covariances for the
            %passed grid.
            %TODO rename grid_covariance_matrix
            lags_matrices = grid.get_lags_matrices();
            lags_X = lags_matrices{1};
            lags_Y = lags_matrices{2};
            cov_mat = obj.covariance_func(lags_X, lags_Y);
        end
        
        function cov_mat = covariances_on_positive_grid(obj, grid)
            %This functions returns a matrix of the covariances for only
            %positive lags in both axis.
%             grid.assertRectangular();
            [lags_X, lags_Y] = grid.get_positive_lags_grid();
            cov_mat = obj.covariance_func(lags_X, lags_Y);
        end
        
        function cov_mat = covariances_on_negative_grid(obj, grid)
            %This functions returns a matrix of the covariances for only
            %positive lags in both axis.
%             grid.assertRectangular();
            [lags_X, lags_Y] = grid.get_negative_lags_grid();
            cov_mat = obj.covariance_func(lags_X, lags_Y);
        end
        
        function mat = covariances_prime_positive_lags(obj, grid)
            %Similar to covariances_on_positive_grid, except for the fact
            %that the derivative of the covariance at lags is returned,
            %with respect to each parameter. The different parameters
            %correspond to the third dimension of the returned tensor.
            grid.assertRectangular();
            [lags_X, lags_Y] = grid.get_positive_lags_grid();
            mat = obj.covariance_prime(lags_X, lags_Y);
        end
        
        function mat = covariances_prime_negative_lags(obj, grid)
            %Similar to covariances_on_negative_grid, except for the fact
            %that the derivative of the covariance at lags is returned,
            %with respect to each parameter. The different parameters
            %correspond to the third dimension of the returned tensor.
            grid.assertRectangular();
            [lags_X, lags_Y] = grid.get_negative_lags_grid();
            mat = obj.covariance_prime(lags_X, lags_Y);
        end
        
        function sdf = spectral_density_on_grid(obj, grid)
            %This method returns the values of the spectral density
            %function on the grid of Fourier frequencies correspondies to
            %the spatial grid passed.
            %grid: RectangularGrid
            grid.assertRectangular();
            frequency_grid = grid.get_fourier_grid();
            sdf = frequency_grid.evaluate_spectral_density(obj);
        end
        
        function aliased_sdf = aliased_spectral_density(obj, grid, nb)
            %This method approximates the aliased spectral density of the
            %process by truncation of the infinite sum.
            grid.assertRectangular();
            frequency_grid = grid.fourier_grid();
            aliased_sdf = Sample(frequency_grid);
            for k = -((nb-1)):(nb-1)
                for l = (-(nb-1)):nb-1
                    shift = 2 * pi .* [k l] ./ grid.deltas;
                    frequency_grid.shift(shift);
                    sdf = frequency_grid.evaluate_spectral_density(obj);
                    frequency_grid.shift(- shift);
                    aliased_sdf = aliased_sdf + sdf;
                end
            end
            aliased_sdf = SampleOnFourierGrid(aliased_sdf);
        end

        function sdf = expected_periodogram(obj, grid, P)
            %Returns the expectation of the periodogram
            sdf = P.compute_expectation(obj, grid);
        end
    end
    
    %Plot methods------------------------------------------------------
    methods
        function plot(obj, grid, close_on_enter, group_graphs)
            switch nargin
                case 2
                    close_on_enter = false;
                    group = false;
                case 3
                    group = false;
                case 4
                    group = true;
            end
            if ~group
                group1 = GroupImagesc();
            else
                group1 = group_graphs;
            end
            %Plots some of the plots below.
            a = obj.plot_covariances_on_quadrant(grid);
            b = obj.plot_spectral_density_on_grid(grid, group1);
            c = obj.plot_expected_periodogram(grid, group1);
            %We try to plot a simulated example
            try
                d = obj.plot_simulated_sample(grid);
                try_failed = false;
            catch e
                disp(e.message);
                try_failed = true;
            end
            s_v = grid.simulate(obj, RandomGenerator(randi(1000)));
%             s_v.setName('Simulated data');
            e = obj.plot_residuals(s_v);
            if close_on_enter
                input('Press enter to close the figures.');
                a.delete();
                b.delete();
                c.delete();
                if not(try_failed)
                    d.delete();
                end
                e.delete();
            end
        end
        
        function h = plot_covariances_on_grid(obj, grid)
            h=figure;
            imagesc(obj.covariances_on_grid(grid));
            title(['Covariance of ' obj.model_family.model_family_name])
            colorbar();
        end
        
        function h = plot_covariances_on_quadrant(obj, grid, group_graphs)
            %Plots the model's covariance at lags specified by the
            %upper-quadrant of possible lags on the rectangular grid which
            %is passed.
            switch nargin
                case 3
                    group = true;
                otherwise
                    group = false;
            end
            h=figure;
            %First plot
            subplot(121);
            covariances = obj.covariances_on_positive_grid(grid);
            if group
                imagesc_(covariances, group_graphs);
            else
                imagesc(covariances);
            end
            fig_title = ['Covariances - ' obj.toShortString()];
            title(fig_title);
            colorbar();
            %Second plot
            subplot(122);
            plot((0 : grid.N-1) * grid.delta_x, covariances(:,1));
            title('Covariances along x-axis');
            axis('tight')
        end
        
        function h = plot_spectral_density_on_grid(obj, grid, group_graphs)
            switch nargin
                case 3
                    group = true;
                otherwise
                    group = false;
            end
            sdf = obj.spectral_density_on_grid(grid);
            figure_name = ['Spectral density on Fourier grid'];
            if ~group
                h = sdf.plot(1, figure_name);
            elseif group
                h = sdf.plot(1, figure_name, group_graphs);
            end
        end
        
        function h = plot_expected_periodogram(obj, grid, group_graphs)
            switch nargin
                case 3
                    group = true;
                otherwise
                    group = false;
            end
            P = Periodogram();
            expected_p = P.compute_expectation(obj, grid);
            if group
                h = expected_p.plot(1, 'Expected periodogram', ...
                    group_graphs);
            else
                h = expected_p.plot(1, 'Expected periodogram');
            end
        end
        
        function h = plot_simulated_sample(obj, grid)
            sample = grid.simulate(obj, RandomGenerator(randi(1000)));
            h = sample.plot();
        end
        
        function plot_aliased_spectral_density(obj, grid, nb)
            sdf = obj.aliased_spectral_density(grid, nb);
            sdf.plot();
        end
        
        function plot_averaged_statistic(obj, grid, statistic, nb_samples)
            average = 0;
            for k=1:nb_samples
                sample = obj.simulate(grid);
                T = statistic.compute(sample);
                average = Model.update_average(T, average, k);
            end
            fig_title = ['Averaged (' num2str(nb_samples) ') '];
            fig_title = [fig_title  statistic.name];
            statistic.plot_values(average, fig_title);
        end
    end
    
    %Others -----------------------------------------------------------
    methods
        function estimate(obj, sample, estimator)
            estimator.estimate(sample, obj);
        end
        
        function s = toString(obj)
            %TODO Correct function
            %Returns a string describing the object. 
            full_params = obj.model_family. ...
                full_parameter_vector(obj.parameters);
            fam_name = obj.model_family.model_family_name;
            params_str = '';
            for i_p = 1:length(obj.parameters)
                params_str = [params_str obj.getParameterName(i_p) ...
                    ':' num2str(full_params(i_p)) '\n'];
            end
            s = [fam_name '\n' params_str];
        end
        
        function s = toShortString(obj)
            full_params = obj.model_family. ...
                full_parameter_vector(obj.parameters);
            fam_name = obj.model_family.get_name();
            params_str = '';
            for i_p = 1:length(full_params)
                params_str = [params_str num2str(full_params(i_p)) ', '];
            end
            s = [fam_name '(' params_str(1:end-2) ')'];
        end
    end
    
    methods
        function sample_v = simulate(obj, sample, generator)
            switch nargin
                case 2
                    passed_generator = false;
                case 3
                    passed_generator = true;
                    generator.turnOn();
            end
            values = sample.grid.simulate_values(obj);
            %We use the mask
            values = values(sample.mask);
            sample_v = ValuedSample(sample, values);
            if passed_generator
                generator.turnOff();
            end
            sample_v.setName('Simulated data');
        end
        
        function residuals = residuals(obj, sample)
            %Returns the residuals of the model, transformed so that if the
            %passed sample follows the model distribution, then the
            %residuals are expected to be uniformely distributed over
            %[0,1].
            %Args:
            %sample ValuedSample The valued sample for which we wish to
            %compute the residuals.
            values = sample.get_values();
            grid = sample.grid;
            cov_mat = obj.covariances_on_grid(grid);
            L = chol(cov_mat);
            %The following quantity is expected to behave like white noise
            whitened = L\values;
            mu = 0;
            sigma = 1;
            normal_distr = makedist('Normal',mu,sigma);
            %We compose by the cdf of the standard normal distribution,
            %which ideally should lead to a uniform distribution on [0,1].
            residuals_values = cdf(normal_distr, whitened);
            residuals = Sample(grid);
            residuals.set_values(residuals_values);
        end
        
        function h = plot_residuals(obj, sample)
            res = obj.residuals(sample);
            h = figure;
            subplot(121)
            title_text = ['Residuals of the model over the grid'];
            res.plot(0, title_text);
            subplot(122)
            histogram(res.get_values(), 'binwidth', 0.1);
            title('Residuals amplitude distribution');
            suptitle(['Model residuals for ' sample.getName()]);
        end
    end
end

