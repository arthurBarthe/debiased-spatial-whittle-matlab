classdef TestEstimatorOnModel < handle & InterfaceTest
    %This class defines the structure for a test of an estimator for a
    %specific model (for instance a Matern covariance function with given
    %parameters).
    %Properties
    %name:  String  Name of the test, used when the results are prompted.
    %model: Model Model for which we test an estimator.
    %estimates: double{nb_samples][nb_params] An array to store the
    %parameter estimates. The first dimension corresponds to the different
    %simulates samples, the second dimension corresponds to the parameter
    %estimates.
    %sample: Sample Sample used to do the test.
    %cpu_time: double[nb_samples] CPU times for the estimation for each
    %simulated sample.
    %generator: RandomGenerator The random generator object used for
    %simulating the samples.
    
    properties
        name
        %results_folder is the path to the folder where results will be
        %saved.
    end
    
    properties (Access=protected)
        model
        estimator
        grid
        cpu_time
        generator
    end
    
    methods
        function obj = TestEstimatorOnModel(model, grid, estimator)
            assert(isa(model, 'Model'));
            assert(isa(grid, 'Grid'));
            assert(isa(estimator, 'ParameterEstimator'));
            obj.grid = grid;
            obj.estimator = estimator;
            %default number of samples is 100
            obj.nb_samples = 100;
            obj.model = model;
            %Default name of the test
            %TODO change this
            obj.name = [num2str(grid.N) ' - ' estimator.getName()];
            %By default the random generator is initialized as follows.
            %This behaviour can be changed by calling the method setSeed.
            obj.generator = RandomGenerator(randi(10000));
        end
        
        function setName(obj, n)
            %Sets the name of this test.
            assert(isa(n, 'char'));
            obj.name = n;
        end
        
        function n = getName(obj)
            n = obj.name;
        end
                
        function run(obj)
            %This method runs the simulations and estimations. If the
            %property write_to_file is set to true it will write each
            %estimation result into a file (NOT IMPLEMENTED YET)
            %We define the estimated model
            %Define the arrays used to store the test results
            nb_parameters = obj.model.getNbParams();
            obj.cpu_time = zeros(obj.nb_samples, 1);
            obj.estimates = zeros(obj.nb_samples, nb_parameters);
            estimated_model = Model(obj.model.model_family);
            disp(['Running test ' obj.name '...']);
            h = waitbar(0, 'Starting...');
            for k = 1 : obj.nb_samples
                %Update the progress bar
                waitbar((k-1) / obj.nb_samples, h, 'In progress...');
                %Simulate a sample
                valued_sample = obj.grid.simulate(obj.model, obj.generator);
                
                %Estimate the estimated_model
                tic;
                obj.estimator.estimate(valued_sample, estimated_model);
                cpu_t = toc;
                %Save the estimated parameters in the array
                obj.new_entry(estimated_model.getParameters(), ...
                    cpu_t, k);
            end
            h.delete();
        end
        
        function new_entry(obj, estimate, cpu_time, k)
            %Records the new entry in the estimates arrays, at position k.
            obj.estimates(k,:) = estimate;
            obj.cpu_time(k) = cpu_time;
        end
        
        function plot(obj, save_figs, format_fig, groups)
            %This function plots a histogram of the estimated parameters
            %for all simulated samples. It also plots the covariance matrix
            %of the estimates (so if the estimated parameter vector is of
            %length 3, the corresponding covariance matrix is 3x3).
            %Histogram of estimates
            group = false;
            switch nargin
                case 1
                    save_figs = false;
                    format_fig = '.fig';
                case 2
                    format_fig = '.fig';
                case 4
                    group = true;
            end
            h1 = figure();
            %sample name to be used in figures titles.
            sample_name = obj.sample.getName();
            est_name = obj.estimator.getName();
            nb_estimates = obj.model.getNbParams();
            true_param_values = obj.model.getParameters();
            for i_estimate = 1 : nb_estimates
                %One histogram per parameter estimate
                subplot(100+nb_estimates*10+i_estimate);
                nbins = max(20, obj.nb_samples/10);
                if group
                    h = histogram_(obj.estimates(:,i_estimate), nbins, groups{i_estimate});
                else
                    h = histogram(obj.estimates(:,i_estimate), nbins);
                end
                YLim = h.Parent.YLim;
                YLim = YLim(2);
                %A red line indicating the true parameter value
                true_value = true_param_values(i_estimate);
                line([true_value true_value], [0 YLim], ...
                    'color', 'r', 'linewidth', 2);
                %Title: the name of the parameter
                title(obj.model.getParameterName(i_estimate));
            end
            suptitle(['Distribution of estimates - ' sample_name ' - ' ...
                est_name]);
            %TODO move the covariance plot to another method
%             %Plot of covariance matrix
%             cov_mat = obj.sample_cov_mat();
%             h2 = figure();
%             imagesc(cov_mat);
%             colorbar();
%             title(['Sample covariance matrix of estimates - ' ...
%                 sample_name ' - ' est_name]);
            if save_figs
                saveas(h1, [obj.results_folder '/histEstimates' obj.name format_fig]);
                saveas(h2, [obj.results_folder '/covEstimates' obj.name format_fig]);
            end
        end
        
        function s = summary(obj)
            %This method returns a string with the basic statistics obtained from the
            %estimated parameters.
            m = obj.getMeanOfEstimates();
            std = obj.getSTDofEstimates();
            b = obj.getBiasOfEstimates();
            cpu = obj.getMeanCPUtime();
            rmse = obj.getRMSEofEstimates();
            s = ['Bias of estimates: ' num2str(b) '\n'];
            s = [s 'STD of estimates: ' num2str(std) '\n'];
            s = [s 'RMSE of estimates: ' num2str(rmse) '\n'];
            s = [s 'Mean CPU time: ' num2str(cpu) '\n\n'];
        end
        
        function printSummary(obj)
            s = ['Summary of test - ' obj.getName() '\n' ...
                obj.summary()];
            fprintf(s);
        end
        
        function writeToTextFile(obj)
            filepath = [obj.results_folder '/' obj.getName() '.txt'];
            fileID = fopen(filepath, 'wt');
            fprintf(fileID, obj.toString());
            fclose(fileID);
        end
        
        function s = toString(obj)
            title_text = ['Summary of test - ' obj.getName() '\n'];
            title_2_text = 'Test parameters\n';
            text_2 = ['Number of samples:' num2str(obj.nb_samples) '\n\n'];
            text_21 = obj.model.toShortString();
            text_22 = obj.sample.toString();
            text_3 = obj.estimator.toString();
            title_4_text = '\n\nSummary of estimates\n';
            text_4 = obj.summary();
            s = [title_text title_2_text text_2 text_21 '\n' text_22  ...
                 '\n' text_3 ...
                title_4_text text_4];
        end
        
        function est_array = get_estimates(obj)
            %Returns the array of estimates.
            est_array = obj.estimates;
        end
        
        function cov_mat = sample_cov_mat(obj)
            %This method returns the sample covariance matrix of estimates.
            cov_mat = cov(obj.estimates);
        end
        
        function m = getMeanOfEstimates(obj)
            %This method returns the means of estimates.
            m = mean(obj.estimates, 1);
        end
        
        function b = getBiasOfEstimates(obj)
            %This method returns the bias of estimates.
            m = obj.getMeanOfEstimates();
            b = m - obj.model.getParameters();
        end
        
        function b_ = getNormalizedBias(obj)
            %Returns the normalized bias of estimates
            b_ = obj.getBiasOfEstimates() ./ obj.model.getParameters();
        end
        
        function v = getVarOfEstimates(obj)
            %This method returns the variance of the estimates
            v = var(obj.estimates, 1);
        end
        
        function std = getSTDofEstimates(obj)
            %This method returns the std of the estimates
            std = sqrt(obj.getVarOfEstimates());
        end
        
        function std_ = getNormalizedSTD(obj)
            %Returns the STD normalized by the true values.
            std_ = obj.getSTDofEstimates() ./ obj.model.getParameters();
        end
        
        function time = getMeanCPUtime(obj)
            %This method returns the mean cpu time
            time = mean(obj.cpu_time);
        end
        
        function rmse = getRMSEofEstimates(obj)
            %This method returns the RMSE of the estimates
            b = obj.getBiasOfEstimates();
            v = obj.getVarOfEstimates();
            rmse = sqrt(b.^2 + v);
        end
        
        function rmse_ = getNormalizedRMSE(obj)
            rmse_ = obj.getRMSEofEstimates() ./ obj.model.getParameters();
        end
        
        function setSeed(obj, seed)
            obj.generator = RandomGenerator(seed);
        end
    end
end

