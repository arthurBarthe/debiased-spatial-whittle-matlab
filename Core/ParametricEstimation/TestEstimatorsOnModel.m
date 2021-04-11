classdef TestEstimatorsOnModel < handle & InterfaceTest
    %This class defines tests of estimators on a specific model.
    %Different estimators can be compared by creating different instances
    %from this class with different estimators.
    
    properties
        name
        %results_folder is the path to the folder where results will be
        %saved.
    end
    
    properties (Access=protected)
        model
        sample
        cpu_time
        generator
        estimators_list
        tests
    end
    
    methods
        function obj = TestEstimatorsOnModel(model, sample, estimators)
            assert(isa(model, 'Model'));
%             assert(isa(sample, 'Sample'));
            obj.sample = sample;
            obj.estimators_list = estimators;
            obj.nb_samples = 10; %default
            obj.model = model;
            obj.generator = RandomGenerator(randi(10000));
            obj.tests = {};
            for i = 1 : length(obj.estimators_list)
                obj.tests{i} = TestEstimatorOnModel(model, sample, ...
                    obj.estimators_list{i});
            end
        end
        
        function setName(obj, n)
            obj.name = n;
        end
        
        function n = getName(obj)
            n = obj.name;
        end
        
        function plot_model(obj)
            close all;
            obj.model.plot(obj.sample.grid);
            valued_sample = obj.sample.simulate(obj.model);
            %Plot periodogram and its expectation
            g = GroupImagesc();
            P = Periodogram();
            expectedP = P.compute_expectation(obj.model, valued_sample);
            P.plot_values(abs((P.compute(valued_sample) - expectedP) ./ expectedP),...
                '(Periodogram-expected) ./ expected', false, g);
            %Plot tapered periodogram and its expectation
            taper = Taper(@hanning, 'Hanning');
            tapered_P = TaperedPeriodogram(Periodogram(), taper);
            expectedP = tapered_P.compute_expectation(obj.model, valued_sample);
            tapered_P.plot_values(abs((tapered_P.compute(valued_sample) - expectedP) ./ expectedP),...
                '(tPeriodogram-texpected) ./ texpected', false, g);
        end
        
        function plot_model_NEW(obj)
            %Plots the fitted quantities from the used likelihood
            %estimators.
            %We first simulate a valued sample
            valued_sample = obj.sample.simulate(obj.model);
            for i = 1 : length(obj.estimators_list)
                estimator = obj.estimators_list{i};
                if ~isa(estimator, 'LikelihoodEstimator')
                    continue
                end
                figure('name', estimator.name);
                %Plot the fitted quantity
                subplot(121);
                imagesc(10*log10(estimator.Tbar(obj.model, obj.sample)));
                title('Fitted quantity');
                %Plot the computed statistic for the simulated sample
                subplot(122);
                imagesc(10*log10(estimator.statistic(valued_sample)));
                title('Realization example');
            end
        end
                
        function run(obj)
            %This method runs the simulations and estimations. If the
            %property write_to_file is set to true it will write each
            %estimation result into a file (NOT IMPLEMENTED YET)
            estimated_model = Model(obj.model.model_family);
            %Array where estimates will be stored
            nb_estimators = length(obj.estimators_list);
            nb_params = obj.model.getNbParams();
            obj.estimates = zeros(obj.nb_samples, nb_params, ...
                nb_estimators);
            obj.cpu_time = zeros(obj.nb_samples, nb_estimators);
            for k = 1 : obj.nb_samples
                %Simulate a sample
                valued_sample = obj.sample.simulate(obj.model, obj.generator);
                %Estimate the estimated_model
                for i_estimator = 1 : nb_estimators
                    estimator = obj.estimators_list{i_estimator};
                    estimator.estimate(valued_sample, estimated_model);
                    %Save the estimated parameters in the array
                    obj.estimates(k,:, i_estimator) = ...
                        estimated_model.parameters;
                    %Save computation time
                    obj.cpu_time(k, i_estimator) = estimator.getCPUtime();
                    est_params = estimated_model.parameters;
                    obj.tests{i_estimator}.new_entry(est_params, ...
                        estimator.getCPUtime(), k);
                end
            end
        end
        
        function plot(obj, save_figs, format_fig)
            %This method calls the plot methods of each test (each
            %corresponding to one estimator)
            nb_params = obj.model.getNbParams();
            groups = cell(nb_params,1);
            for i = 1 : nb_params
                groups{i} = GroupHist();
            end
            for e = obj.tests
                e{1}.plot(false, false, groups);
            end
        end
        
        function s = summary(obj)
            %This method returns the basic statistics obtained from the
            %estimated parameters.
            error('Not implemented');
        end
        
        function printSummary(obj)
            %Prints a summary of the test, by calling the printSummary
            %method of the tests corresponding to the different estimators.
            disp('------------------------------------------------------');
            disp('Model:');
            disp(obj.model.toShortString());
            for e = obj.tests
                e{1}.printSummary();
            end
        end
        
        function print_and_plot(obj)
            %Shortcut method
            obj.printSummary();
            obj.plot()
        end
        
        function writeToTextFile(obj)
            filepath = [obj.results_folder '/' obj.getName() '.txt'];
            fileID = fopen(filepath, 'wt');
            fprintf(fileID, obj.toString());
            fclose(fileID);
        end
        
        function s = toString(obj)
            error('Not implemented');
        end
        
        function est_array = get_estimates(obj)
            est_array = obj.estimates;
        end
        
        function m = getMeanOfEstimates(obj)
            %This method returns the means of estimates. 
            m = mean(obj.estimates, 1);
            [a,b,c] = size(m);
            %Now m has size (1,nb_parameters, nb_estimators)
            m = reshape(m, b, c);
            %Now m has size (nb_parameters, nb_estimators). We transpose.
            m = m';
        end
        
        function b = getBiasOfEstimates(obj)
            %This method returns the bias of estimates.
            m = obj.getMeanOfEstimates();
            b = m - obj.model.parameters;
        end
        
        function v = getVarOfEstimates(obj)
            %This method returns the variance of the estimates
            v = var(obj.estimates, 1);
            [a,b,c] = size(v);
            v = reshape(v, b, c);
            v = v';
        end
        
        function std = getStdOfEstimates(obj)
            %Returns the standard deviations
            std = sqrt(obj.getVarOfEstimates());
        end
        
        function time = getMeanCPUtime(obj)
            %This method returns the mean cpu time
            time = mean(obj.cpu_time, 1);
            time = time';
        end
        
        function rmse = getRMSEofEstimates(obj)
            %This method returns the RMSE of the estimates. Rows
            %correspond to different estimators, columns correspond to
            %different parameters.
            b = obj.getBiasOfEstimates();
            v = obj.getVarOfEstimates();
            rmse = sqrt(b.^2 + v);
        end
        
        function setSeed(obj, seed)
            obj.generator = RandomGenerator(seed);
        end
        
        function set_generator(obj, random_g)
            obj.generator = random_g;
        end
        
        function m = get_model(obj)
            m = obj.model;
        end
    end
end



