classdef TestIncreasingDomain < InterfaceTest & handle 
    %This class defines the structure of a test of an estimator within
    %increasing domain, i.e. we simulate/estimate for a family of grids
    %with increasing sizes.
    
    properties
        model
        base_grid
        list_of_ratios
        estimator
        tests
    end
    
    methods
        function obj = TestIncreasingDomain(model, grid, estimator)
            obj.model = model;
            obj.base_grid = grid;
            obj.estimator = estimator;
        end
        
        function set.list_of_ratios(obj, l)
            obj.list_of_ratios = l;
        end
        
        function run(obj)
            nb_ratios = length(obj.list_of_ratios);
            obj.tests = cell(nb_ratios, 1);
            obj.estimates = zeros(obj.nb_samples, obj.model.getNbParams(), ...
                nb_ratios);
            for i = 1 : nb_ratios
                obj.tests{i} = obj.runInstance(i);
            end
        end
        
        function test_i = runInstance(obj, i)
            %This method runs the instance i, i.e. the test for the sample
            %with size determined by list_of_ratios(i) and the object's
            %sample attribute.
            g = obj.base_grid;
            r = obj.list_of_ratios(i);
            shape_i = g.shape * r;
            grid_i = RectangularGrid(shape_i, g.deltas);
            %Test for this grid
            test_i = TestEstimatorOnModel(obj.model, grid_i, ...
                obj.estimator);
            test_i.nb_samples = obj.nb_samples;
            test_i.run();
%             save(['incompleteSimsEmbedding_' '_' num2str(fix(clock))]);
        end
        
        function [b,v,rmse] = summary(obj)
            %This method returns summary statistics about the estimates.
            %Bias, variance, RMSE, for each value of N and for each
            %parameter. Therefore the returned array is a matrix.
            true_params = obj.model.parameters;
            nb_ratios = length(obj.list_of_ratios);
            true_params = repmat(true_params', 1, nb_ratios);
            m = squeeze(mean(obj.estimates, 1));
            v = squeeze(var(obj.estimates, 1));
            b = m-true_params;
            rmse = sqrt(b.^2 + v);
            disp('Biases');
            disp(b);
            disp('Std deviation')
            disp(sqrt(v));
            disp('rmse');
            disp(rmse)
        end
        
        function plot(obj, save_figs, format_fig)
            switch nargin
                case 1
                    save_figs = false;
                    format_fig = '.fig';
                case 2
                    format_fig = '.fig';
            end
            %We first plot histograms of estimates to show the distribution
            %for each sample size.
            nb_ratios = length(obj.list_of_ratios);
            nb_rows = nb_ratios;
            nb_cols = 1;
            for k=1:obj.model.getNbParams()
                param_name = obj.model.getParameterName(k);
                param_value = obj.model.parameters(k);
                h(k) = figure();
                for i = 1 : nb_ratios
                    subplot_id = 100*nb_rows+10*nb_cols+i;
                    AxesHandle(i) = subplot(subplot_id);
                    %Histogram of estimates
                    nbins = obj.nb_samples/25;
%                     histogram(obj.estimates(:, k, i), nbins);
                    histogram(obj.tests{i}.estimates, nbins);
                    %Determine title
                    r = obj.list_of_ratios(i);
                    N_text = num2str(obj.base_grid.grid.N * r);
                    M_text = num2str(obj.base_grid.grid.M * r);
                    title_text = ['Size ' N_text ' x ' M_text];
                    title(title_text);
                    %Same x-axis
                    allXLim = get(AxesHandle, {'XLim'});
                    allXLim = cat(2, allXLim{:});
                    allXLim = cat(2, allXLim, param_value);
%                     set(AxesHandle, 'XLim', [min(allXLim), max(allXLim)]);
                    set(AxesHandle, 'XLim', [0, 16]);
                    %Same y-axis
                    allYLim = get(AxesHandle, {'YLim'});
                    allYLim = cat(2, allYLim{:});
                    set(AxesHandle, 'YLim', [min(allYLim), max(allYLim)]);
                    %Red vertical line for the true parameter value
                    line([param_value param_value], [0 max(allYLim)], ...
                        'color', 'r', 'linewidth', 2)
                end
                title_ = [obj.estimator.getName() ' - ' ...
                    obj.model.toShortString() ' - ' param_name];
                suptitle(title_);
                clear AxesHandle;
            end
            %We then plot the bias, variance, and RMSE as a function of the
            %sample size
%             figure();
            
        end
    end
end

