classdef ModelFamily < handle & matlab.mixin.Copyable
    %This class defines the representation of model family.
    %
    %This includes defining the covariance function as a function of some
    %parameters. One can also fix the value of a parameter.
    %
    %Attributes:
    %   model_family_name: String, name for this model family. 
    %   parameter_names: Strings
    
    properties
        model_family_name
        parameter_names
        fixed_parameters
        fixed_parameter_values
        parameters_lower_bound
        parameters_upper_bound
    end
    
    methods (Abstract, Access = protected)
        cov = covariance_(obj, parameters, lag_X, lag_Y)
        cov_prime = covariance_prime_(obj, parameters, lag_X, lag_Y)
        sdf = spectral_density_(obj, parameters, freq_X, freq_Y)
    end
    
    methods
        function obj = ModelFamily(family_name, parameter_names, fixed_p)
            obj.model_family_name = family_name;
            obj.parameter_names = parameter_names;
            obj.fixed_parameters = logical(fixed_p);
        end
        
        function cov = covariance(obj, parameters, lag_X, lag_Y)
            assert(all(size(lag_X) == size(lag_Y)));
            cov = obj.covariance_(obj.full_parameter_vector(parameters), ...
                lag_X, lag_Y);
        end
        
        function cov = covariance_prime(obj, parameters, lag_X, lag_Y)
            assert(all(size(lag_X) == size(lag_Y)));
            cov = obj.covariance_prime_(obj.full_parameter_vector(parameters), ...
                lag_X, lag_Y);
        end
        
        function sdf = spectral_density(obj, parameters, freq_X, freq_Y)
            sdf = obj.spectral_density_(obj.full_parameter_vector(...
                parameters), freq_X, freq_Y);
        end
        
        function name = get_name(obj)
            name = obj.model_family_name;
        end
        
        function new_parameters = ensure_parameters_bounds(obj, parameters)
            %Returns a parameter vector where the parameters have been
            %reflected around their lower and upper bound.
            lower_bound = obj.parameters_lower_bound;
            upper_bound = obj.parameters_upper_bound;
            nb_params = obj.get_nb_parameters();
            range = upper_bound - lower_bound;
            q1 = ones(1, nb_params);
            q2 = ones(1, nb_params);
            i = upper_bound < Inf;
            j = lower_bound > - Inf;
            k = i & j;
            q1(k) = range(k) ./ (max(range(k), range(k) + lower_bound(k) - parameters(k)));
            q2(k) = range(k) ./ (max(range(k), range(k) + parameters(k)-upper_bound(k)));
            new_parameters = parameters;
            new_parameters(j) = lower_bound(j) + abs(parameters(j) - lower_bound(j)) ...
                .* q1(j);
            new_parameters(i) = upper_bound(i) - abs(parameters(i)-upper_bound(i))...
                .* q2(i);
        end
        
        function full_p = full_parameter_vector(obj, params)
            %This method returns the full vector of parameters, accounting
            %for the parameters that are fixed.
            %Args:
            %   params:     Double[px1], vector of parameters.
            nb_params = length(obj.parameter_names);
            full_p = zeros(1, nb_params);
            full_p(~obj.fixed_parameters) = params;
            full_p(obj.fixed_parameters) = obj.fixed_parameter_values;
        end
        
        function set_fixed_parameter_values(obj, values)
            obj.fixed_parameter_values = values;
        end
            
        function name = get_parameter_name(obj, i)
            %This method returns the parameter name with index i. Note that
            %fixed parameters are ignored.
            %Args:
            %   i:  int, index of the parameter within the parameter
            %       vector.
            non_fixed_params = obj.parameter_names(~obj.fixed_parameters);
            name = non_fixed_params{i};
        end
        
        function display_parameter(obj, i, value, sample)
            i = find(cumsum(~obj.fixed_parameters) == i);
            i=i(1);
            obj.display_parameter_(i, value, sample);
        end
        
        function print_parameter_names(obj)
            for i = 1 : obj.get_nb_parameters()
                lower_bound = ['[' num2str(obj.parameters_lower_bound(i))];
                upper_bound = [num2str(obj.parameters_upper_bound(i)) ']'];
                name = obj.get_parameter_name(i);
                disp([num2str(i) '. ' name  lower_bound ', ' upper_bound '.']);
            end
        end
        
        function nb_params = get_nb_parameters(obj)
            %This method returns the actual number of parameters, i.e.
            %those that are not fixed and can be changed.
            nb_params = sum(~obj.fixed_parameters);
        end
        
        function set_parameters_lower_bound(obj, lower_bound)
            assert(length(lower_bound) == obj.get_nb_parameters());
            obj.parameters_lower_bound = lower_bound;
        end
        
        function set_parameters_upper_bound(obj, upper_bound)
            assert(length(upper_bound) == obj.get_nb_parameters());
            obj.parameters_upper_bound = upper_bound;
        end
        
        function model = get_random_model(obj, random_g)
            %Returns a model belonging to the instance's family where
            %parameters have been sampled uniformely within their
            %admissible range.
            switch nargin
                case 2
                    use_generator = true;
                otherwise
                    use_generator = false;
            end
            if use_generator
                random_g.turnOn();
            end
            lower_b = obj.parameters_lower_bound;
            upper_b = obj.parameters_upper_bound;
            nb_params = obj.get_nb_parameters();
            params = lower_b + ...
                (upper_b - lower_b) .* rand(1, nb_params);
            model = Model(params, obj);
            if use_generator
                random_g.turnOff();
            end
        end
        
        function m_fam = fix_parameters(obj, model, fixed)
            %Returns a new model family where some parameters have been
            %fixed. 
            %Args
            %model  Model   The model from which parameter values are taken
            %fixed  bool[p] Logical array indicating for each parameter of
            %model if the value is fixed or not in the new family.
            m_fam = obj.copy();
            nb = length(obj.fixed_parameter_values);
            old_fixed = obj.fixed_parameters;
            old_values = obj.fixed_parameter_values;
            values = model.getParameters();
            values = values(fixed);
            fixed = obj.convert_selection(fixed);
            full_values = zeros(1, nb);
            full_values(fixed) = values;
            full_values(old_fixed) = old_values;
            new_values = full_values(fixed | old_fixed);
            m_fam.set_fixed_parameters(fixed | old_fixed, new_values);
        end
    end
    
    methods (Access = private)
        function new_sel = convert_selection(obj, sel)
            %Converts the selection to a selection vector setting zeros for
            %fixed parameters.
            fixed = obj.fixed_parameters;
            new_sel = false(1, length(fixed));
            new_sel(~fixed) = sel;
        end
        
        function set_fixed_parameters(obj, bool, values)
            assert(sum(bool) == length(values));
            obj.fixed_parameters = bool;
            obj.fixed_parameter_values = values;
        end
    end
    methods (Access = protected)
        function text = value_to_text(obj, i, value, sample)
            text = num2str(value);
        end
        
        function display_parameter_(obj, i, value, sample)
            param_name = obj.parameter_names{i};
            param_value = obj.value_to_text(i, value, sample);
            disp([param_name ' : ' param_value]);
        end
    end
end

