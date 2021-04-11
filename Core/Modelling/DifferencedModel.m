classdef DifferencedModel < Model
    %This class defines a model corresponding to the differenced data
    %obtained from a model. Note that this depends on the grid, and
    %therefore there is no covariance_func function but only functions
    %giving the covariance matrices on grids.
    %Attributes
    %model  Model   The model of the data before applying the differencing
    %operation.
    %
    
    properties
        model
    end
    
    methods
        function obj = DifferencedModel(model)
            obj@Model(model.parameters, model.model_family);
            obj.model = model;
        end
        
        function setParameters(obj, parameters)
            setParameters@Model(obj, parameters);
            obj.model.setParameters(parameters);
        end
        
        function cov = covariance_func(obj, lag_X, lag_Y)
            error('This method does not exist for the differenced model');
        end 
        
        function cov_mat = covariances_on_positive_grid_OLD(obj, grid)
            grid.assertRectangular();
            [lags_X, lags_Y] = grid.get_positive_lags_grid();
            dx = grid.delta_x;
            dy = grid.delta_y;
            cov_mat = 3/2 * obj.model.covariance_func(lags_X, lags_Y) ...
                - 1/2 * obj.model.covariance_func(lags_X, lags_Y + dy) ...
                - 1/2 * obj.model.covariance_func(lags_X, lags_Y - dy) ...
                - 1/2 * obj.model.covariance_func(lags_X + dx, lags_Y) ...
                - 1/2 * obj.model.covariance_func(lags_X - dx, lags_Y) ...
                + 1/4 * obj.model.covariance_func(lags_X + dx, lags_Y - dy) ...
                + 1/4 * obj.model.covariance_func(lags_X - dx, lags_Y + dy);
        end
        
        function cov_mat = covariances_on_positive_grid(obj, grid)
            grid.assertRectangular();
            [lags_X, lags_Y] = grid.get_lags_grid_([-1 -1], ...
                [grid.N grid.M]);
            cov = obj.model.covariance_func(lags_X, lags_Y);
            cov_mat = 3/2 * cov(2:end-1, 2:end-1)...
                - 1/2 * cov(2:end-1, 3:end) ...
                - 1/2 * cov(2:end-1, 1:end-2) ...
                - 1/2 * cov(3:end, 2:end-1) ...
                - 1/2 * cov(1:end-2, 2:end-1) ...
                + 1/4 * cov(3:end, 1:end-2) ...
                + 1/4 * cov(1:end-2, 3:end);
        end
        
        function cov_mat = covariances_on_negative_grid_OLD(obj, grid)
            grid.assertRectangular();
            [lags_X, lags_Y] = grid.get_negative_lags_grid();
            dx = grid.delta_x;
            dy = grid.delta_y;
            cov_mat = 3/2 * obj.model.covariance_func(lags_X, lags_Y) ...
                - 1/2 * obj.model.covariance_func(lags_X, lags_Y + dy) ...
                - 1/2 * obj.model.covariance_func(lags_X, lags_Y - dy) ...
                - 1/2 * obj.model.covariance_func(lags_X + dx, lags_Y) ...
                - 1/2 * obj.model.covariance_func(lags_X - dx, lags_Y) ...
                + 1/4 * obj.model.covariance_func(lags_X + dx, lags_Y - dy) ...
                + 1/4 * obj.model.covariance_func(lags_X - dx, lags_Y + dy);
        end
        
        function cov_mat = covariances_on_negative_grid(obj, grid)
            grid.assertRectangular();
            [lags_X, lags_Y] = grid.get_lags_grid_([-1 -1], ...
                [grid.N grid.M]);
            cov = obj.model.covariance_func(lags_X, lags_Y);
            cov_mat = 3/2 * cov(2:end-1, 2:end-1)...
                - 1/2 * cov(2:end-1, 3:end) ...
                - 1/2 * cov(2:end-1, 1:end-2) ...
                - 1/2 * cov(3:end, 2:end-1) ...
                - 1/2 * cov(1:end-2, 2:end-1) ...
                + 1/4 * cov(1:end-2, 1:end-2) ...
                + 1/4 * cov(3:end, 3:end);
        end
        
        function sample_v = simulate(obj, sample, generator)
            sample_v = obj.model.simulate(sample, generator);
            diff_operator = DifferencingOperator();
            sample_v = diff_operator.apply(sample_v);
        end
    end
    
end

