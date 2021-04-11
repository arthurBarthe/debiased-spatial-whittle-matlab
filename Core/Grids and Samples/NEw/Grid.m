classdef Grid < handle
    %Abstract class defining a grid, i.e. a set of points. This is more
    %like an interface, in the sense that there is no implementation of
    %how the points are stored, but instead we define some methods that any
    %grid should implement.
    
    properties
        nb_dimensions
        name
    end
    
    methods (Static, Access = private)
      function out = getCount()
         persistent Var;
         if isempty(Var)
             Var = 0;
         end
         Var = Var + 1;
         out = Var;
      end
   end
    
    methods (Abstract)
        points = get_points(obj);
        nb_points = get_nb_points(obj);
    end
    
    methods
        %Constructor
        function obj = Grid()
            count = obj.getCount();
            obj.name = ['Grid ' num2str(count)];
        end
        
        function name = getName(obj)
            name = obj.name;
        end
        
        function lag_matrices = get_lags_matrices(obj)
            %Returns two matrices, where lag_matrix_X is the
            %matrix of X-axis distances between points from the sample,
            %points being ordered in the same way as in get_points(). If there
            %are 5 points, the two matrices returned are therefore 5X5.
            points_ = obj.get_points();
            nb_points = obj.get_nb_points();
            lag_matrix_X = zeros(nb_points, nb_points);
            lag_matrix_Y = zeros(nb_points, nb_points);
            for i=1:nb_points
                p_i = points_(i,:);
                for j=i:nb_points
                    p_j = points_(j,:);
                    lag_matrix_X(i,j) = p_j(1)-p_i(1);
                    lag_matrix_Y(i,j) = p_j(2)-p_i(2);
                    lag_matrix_X(j,i) = p_i(1)-p_j(1);
                    lag_matrix_Y(j,i) = p_i(2)-p_j(2);
                end
            end
            lag_matrices = {lag_matrix_X, lag_matrix_Y};
        end
        
        function nb_dims = get_nb_dimensions(obj)
            nb_dims = obj.nb_dimensions;
        end
        
        function covariances_sample = get_covariances_sample(obj, model)
            %Returns a sample of the covariance function defined in the
            %model, evaluated at all points of the grid.
            covariances_sample = Sample(obj);
            points = obj.get_points();
            covariances_values = model.covariance_func(points(:, 1), ...
                points(:, 2));
            covariances_sample.set_values(covariances_values);
        end
        
        function diameter = get_diameter(obj)
            error('Not implemented for general grids.');
        end
        
        function test = assertRectangular(obj)
            test = false;
        end
    end
    
    methods
        function subgrid = filter_leq(obj, point, distance, distance_func)
            switch nargin
                case 4
                    mask = obj.mask_distance_leq(point, distance,...
                        distance_func);
                case 3
                    mask = obj.mask_distance_leq(point, distance);
            end
            subgrid = SubRectangularGrid(obj, mask);
        end
        
        function subgrid = filter_circle(obj, modulus)
            switch nargin
                case 1
                    modulus = pi;
            end
            subgrid = obj.filter_leq([0 0], modulus);
        end
        
        function subgrid = remove_point(obj, point)
            mask = ~obj.mask_eq(point);
            subgrid = SubGrid(obj, mask);
        end
        
        %Methods that return a mask over the points, that corresponds to a
        %variety of conditions.
        function mask = mask_distance_leq(obj, point, distance, ...
                distance_func)
            switch nargin
                case 3
                    distance_func = 'euclidean';
            end
            switch distance_func
                case 'euclidean'
                    distances = sqrt(sum(abs(obj.get_points() - point).^2, 2));
                case 'max'
                    distances = sqrt(max(abs(obj.get_points() - point).^2, [], 2));
            end
            mask = distances <= distance;
        end
        
        function mask = mask_eq(obj, point)
            mask = obj.mask_distance_leq(point, 0);
        end
        
        function mask = mask_distance_l(obj, point, distance)
            %Returns a mask (boolean vector) corresponding to the condition
            %that the distance to point is smaller than distance
            distances = sqrt(sum(abs(obj.get_points() - point).^2, 2));
            mask = distances < distance;
        end
    end
    
    methods
        function plot(obj)
           %Plots the points of the grid
           points = obj.get_points();
           if obj.nb_dimensions == 2
               %In dimension 2 we do a scatter plot
               figure
               disp(obj.name);
               scatter(points(:,1), points(:,2), '*');
               axis('tight');
               title(obj.name);
           end
        end
    end
end

