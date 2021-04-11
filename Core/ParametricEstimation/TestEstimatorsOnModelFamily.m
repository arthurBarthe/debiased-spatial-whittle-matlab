classdef TestEstimatorsOnModelFamily < handle & InterfaceTest
    %This class defines the structure to test different estimators for a
    %model family. More precisely, we create instances of
    %TestestimatorsOnModel for different parameter vector values. Those
    %parameter vector values are selected randomly and uniformly over their
    %range of possible values, defined by the parameter family.
    
    properties
        model_family
        sample
        generator
        estimators_list
        tests
        known_params
        results_table
    end
    
    properties (Access = private)
        nb_estimated_params
        generator_models
        generator_samples
    end
    
    methods
        function obj = TestEstimatorsOnModelFamily(model_family, ...
                sample, estimators)
            obj.model_family = model_family;
            obj.sample = sample;
            obj.estimators_list = estimators;
            obj.tests = {};
            obj.known_params = false(1, model_family.get_nb_parameters());
            obj.nb_estimated_params = model_family.get_nb_parameters()
            obj.results_table = 0;
            obj.set_seeds(randi(1000), randi(1000));
        end
        
        function set_seeds(obj, seed_models, seed_samples)
            obj.generator_models = RandomGenerator(seed_models);
            obj.generator_samples = RandomGenerator(seed_samples);
            obj.generator_models.init();
            obj.generator_samples.init();
        end
        
        function [g_models, g_samples] = get_generators(obj)
            %returns the 2 random number generators used for the choice of
            %models in the model family, and for the simulation of tests.
            g_models = obj.generator_models;
            g_samples = obj.generator_samples;
        end
        
        function set_known_parameters(obj, known_p)
            %Sets the parameters that are considered as known at estimation
            %time. 
            %Args
            %known_p: logical[1xp] vector of booleans, where p is the total
            %number of parameters for the covariance function defined by
            %the model family (ignoring previously fixed parameters).
            obj.known_params = logical(known_p);
            m_fam = obj.model_family;
            s = sum(known_p);
            obj.nb_estimated_params = m_fam.get_nb_parameters() - s;
        end
        
        function run(obj, nb_tests)
            %Runs the whole simulation, made of nb_tests, where each test
            %is for a random model from the model family.
            %Args
            %nb_tests:  int     number of tests to run.
            %
            %We create a progress bar.
            h = waitbar(0, 'Starting...');
            for i_test = 1 : nb_tests
                %Update the progress bar
                waitbar((i_test-1) / nb_tests, h, 'In progress...');
                done = false;
                while ~done
                    %The boolean variable done will be set to true only if
                    %the test succeeds. 
                    %Gets a model from the model_family, with parameters
                    %chosen randomly.
                    model = obj.random_model_from_family();
                    disp('Starting test for the following parameter vector...');
                    disp(num2str(model.get_full_parameters()));
                    pause(5);
                    %Instantiates the test for the model
                    obj.tests{i_test} = TestEstimatorsOnModel(model, ...
                        obj.sample, obj.estimators_list);
                    obj.tests{i_test}.nb_samples = obj.nb_samples;
                    %Passes on the random number generator for samples.
                    obj.tests{i_test}.set_generator(obj.generator_samples);
                    try
                        obj.tests{i_test}.run();
                        obj.tests{i_test}.printSummary();
                        done = true;
                    catch e
                        %If the test failed we show an error message an try to
                        %keep going. 
                        disp('Failed to carry out the test, trying again.');
                        disp('Error was...');
                        disp(e.message);
                    end
                end
            end
            %Close the progress bar
            close(h);
        end
        
        function results = get_results_table(obj)
            %Returns the results table (see build_results_table())
            if obj.results_table == 0
                obj.build_results_table();
            end
            results = obj.results_table;
        end
        
%         function table = get_parameters_table(obj)
%             %Returns a two-dimensional array, where the first dimension
%             %corresponds to different models (different parameter values)
%             %and the second dimension corresponds to the different
%             %parameters.
%             nb_tests = length(obj.tests);
%             nb_params = length(obj
        
        function rankings = get_rankings(obj)
            %Returns the rankings table, which has 4 dimensions.
            %The first dimension indicates the test, the second
            %dimension indicates the estimator, the third dimension 
            %indicates different parameters and the fourth dimension
            %indicates bias, std, or mse. The values indicate the ranking
            %for a given test, in terms of bias/std/rmse, for a parameter,
            %among all estimators.
            res_table = abs(obj.get_results_table());
            [~, sorted_indices] = sort(res_table, 2);
            nb_tests = length(obj.tests);
            nb_estimators = length(obj.estimators_list);
            %TODO nb_params needs to be calculated
            nb_params = obj.nb_estimated_params;
            rankings = zeros(nb_tests, nb_estimators, nb_params, 3);
            for i_test = 1 : nb_tests
                for i_param = 1 : nb_params
                    for i_est = 1 : nb_estimators
                        rankings(i_test, i_est , i_param, 1) = find(sorted_indices(i_test, :, i_param, 1) == i_est);
                        rankings(i_test, i_est , i_param, 2) = find(sorted_indices(i_test, :, i_param, 2) == i_est);
                        rankings(i_test, i_est , i_param, 3) = find(sorted_indices(i_test, :, i_param, 3) == i_est);
                    end
                end
            end
        end
        
        function count = count_firsts(obj, i)
            %Returns the number of times each estimator has finished first
            %in the rankings table. Can also be used for different
            %positions, by changing the value of i (i==2) means we'll
            %return how many times each estimator has obtained at least the
            %i-th best ranking (ie ranking 1 or 2).
            switch nargin
                case 1
                    i = 1;
            end
            table = obj.get_rankings();
            count = sum(table <= i, 1);
        end
        
%         function plot_normalized_rmses(obj)
%             %Produces one plot for e
%             nb_tests = length(obj.tests);
%             nb_estimators = length(obj.estimators_list);
%             %TODO change this
%             nb_params = 1;
%             x = zeros(nb_tests, nb_estimators);
%             y = zeros(nb_tests, nb_estimators);
%             colors = zeros(nb_tests, nb_estimators, 3);
%             for i_estimator = 1 : nb_estimators
%                 est = obj.estimators_list{i_estimator};
%                 for i_test = 1 : nb_tests
%                     .....
%                 end
%             end
%         end
        
        function estimators_names(obj)
            %Prints the list of estimators
            for i = 1 : length(obj.estimators_list)
                disp([num2str(i) ' ' obj.estimators_list{i}.getName()]);
            end
        end
        
        %Plot methods -----------------------------------------------------
        function plot(obj)
            error('Not implemented');
        end
        
        function plot_i(obj, i)
            obj.tests{i}.plot();
        end
        
        function plot_model_i(obj, i)
            obj.tests{i}.plot_model();
        end
        
        function summary(obj)
            error('Not implemented');
        end
        
        function printSummary(obj)
            for t = obj.tests
                t{1}.printSummary();
            end
        end
        
        function print_i(obj, i)
            obj.tests{i}.printSummary();
        end
        
        function print_and_plot_i(obj, i)
            obj.tests{i}.print_and_plot();
        end
        
        %------------------------------------------------------------------
        function save_(obj, nb)
            %Saves the tests into a matlab data file
            %Determine the filename
            date = datetime('today');
            day = date.Day;
            if day <=9
                day_text = ['0' num2str(day)];
            end
            date_text = [num2str(date.Year) num2str(date.Month) day_text];
            text = ['Data/' date_text '-' num2str(nb)];
            class(text)
            
            save(text, obj);
        end
        
        function set_nb_estimated_params(obj, nb)
            obj.nb_estimated_params = nb;
        end
        
        function model = get_example_model(obj)
            %Returns an example of an estimated model
            model = obj.random_model_from_family();
        end
    end
    
    methods (Access = private)
        function model = random_model_from_family(obj)
            %TODO rewrite this mess, even though it works
            %This methods returns a model belonging to the model family
            %provided to the instance, where each parameter is sampled
            %according to a uniform distribution across its range of
            %possible values defined by the lower and upper bounds of the
            %model family.
            model = obj.model_family.get_random_model(obj.generator_models);
            model.fix_parameters(obj.known_params);
        end
        
        function build_results_table(obj)
            %Compute the results table, which is a four dimensional array
            %where the first dimension indicates the test, the second
            %dimension indicates the estimator, the third dimension 
            %indicates different parameters and the fourth dimension
            %indicates bias, std, mse.
            nb_tests = length(obj.tests);
            nb_estimators = length(obj.estimators_list);
            %TODO change nb_params to be flexible
            nb_params = obj.nb_estimated_params;
            obj.results_table = zeros(nb_tests, nb_estimators, nb_params, 3);
            for i_test = 1 : nb_tests
                test = obj.tests{i_test};
                biases = test.getBiasOfEstimates();
                stds = test.getStdOfEstimates();
                rmses = test.getRMSEofEstimates();
                obj.results_table(i_test, :, :, 1) = biases;
                obj.results_table(i_test, :, :, 2) = stds;
                obj.results_table(i_test, :, :, 3) = rmses;
            end
        end
    end 
    
end

