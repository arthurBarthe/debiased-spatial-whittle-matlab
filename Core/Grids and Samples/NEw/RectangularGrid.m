classdef RectangularGrid < SubRectangularGrid
    %This class defines the structure of a rectangular grid. Points are
    %ordered according to the colexicographical order (compare last
    %dimension first, if equal compare the penultimate one, etc.).
    %Attributes
    %shape: [1xd]float   row-vector giving the shape of the grid. The length
    %of this vector is the number of dimensions.
    %deltas: [1xd]float row-vector indicating the regular spacing between
    %observations along each axis.
    
    properties
        shape
        deltas
        origins
        fourier_grid
        sim_id
        saved_simulation
        %Obsolete properties (these are redundant) TODO
        N
        M
        delta_x
        delta_y
    end 
    
    methods
        function obj = RectangularGrid(shape, deltas, origins)
            %Constructor method
            %Args:
            %shape: 1xd row vector, the shape of the rectangular grid
            %deltas: 1xd row vector, the step sizes in each direction
            %origins: 1xd row vector, the location of the "first" point of
            %the grid (in dimension 2, that's the bottom-left corner).
            obj@SubRectangularGrid();
            obj.nb_dimensions = length(shape);
            switch nargin
                case 1
                    deltas = ones(1, obj.nb_dimensions);
                    origins = zeros(1, obj.nb_dimensions);
                case 2
                    origins = zeros(1, obj.nb_dimensions);
            end
            assert(length(shape) == length(deltas) & ...
                length(deltas) == length(origins), ...
                ['The shape, deltas and origins vectors should ' ...
                'be of same length in the definition of a ' ...
                'RectangularGrid instance']);
            obj.shape = shape;
            obj.deltas = deltas;
            obj.origins = origins;
            obj.N = shape(1);
            obj.M = shape(2);
            obj.delta_x = deltas(1);
            obj.delta_y = deltas(2);
            obj.set_base_grid(obj);
            obj.sim_id = 0;
        end
        
        function points = get_points(obj)
            %This method returns the list of points from the grid.
            %TODO implement for larger dimensions also.
            ticks = obj.get_ticks();
            switch obj.nb_dimensions
                case 2
                    [X,Y] = ndgrid(ticks{1}, ticks{2});
                    points = [X(:) Y(:)];
                case 3
                    [X,Y,Z] = ndgrid(ticks{1}, ticks{2}, ticks{3});
                    points = [X(:) Y(:) Z(:)];
            end
        end
        
        function nb_points = get_nb_points(obj)
            %Returns the number of points of the grid.
            nb_points = prod(obj.shape);
        end
        
        function ticks = get_ticks(obj)
            %Returns the ticks on each axis. ticks is a cell with
            %obj.n_dimensions elements, one for each dimension.
            origins_ = double(obj.origins);
            deltas_ = double(obj.deltas);
            ticks = cell(obj.nb_dimensions, 1);
            for i = 1 : obj.nb_dimensions
                ticks{i} = (0 : deltas_(i) : ...
                    deltas_(i) * (obj.shape(i) - 1) );
                ticks{i} = ticks{i} + origins_(i);
            end
        end
        
        function delta_p = deltas_product(obj)
            %Returns the product of the elements from obj.deltas. Used for
            %instance in the computation of the periodogram.
            delta_p = prod(obj.deltas);
        end
        
        function shape_p = shapes_product(obj)
            %Returns the product of the elements from obj.shapes. Used for
            %instance in the computation of the periodogram.
            shape_p = prod(obj.shape);
        end
        
        function diameter = get_diameter(obj)
            %Returns the diameter, a quantity defined by convention as the
            %maximal side length. The diameter is used for instance to
            %determine an initial value in estimating the range parameter
            %of a model.
            diameter = max(obj.shape .* obj.deltas);
        end
        
        function mat = values_to_matrix_form(obj, values)
            %TODO obsolete
            mat = reshape(values, obj.shape);
        end
        
        function covariances_sample = get_covariances_sample(obj, model)
            %Redefines the inherited function.
            covariances_sample = get_covariances_sample@Grid(obj, model);
            covariances_sample = SampleOnRectangularGrid(...
                covariances_sample);
        end
        
        function test = assertRectangular(obj)
            test = true;
        end
    end
    
    methods 
        function sample = simulate(obj, model, generator)
            %Simulates a sample on the rectangular grid, using
            %circulant embedding
            %Args:
            %model: Model, the Gaussian model used for the simulation
            %generator: RandomGenerator, 
            %TODO add reference
            switch nargin
                case 2
                    generator = RandomGenerator(randi(1000));
            end
            cov = @(h)model.covariance_func(h(2) * obj.deltas(2),...
                h(1) * obj.deltas(1));
            N2 = obj.N;
            M2 = obj.M;
            generator.turnOn();
%             if mod(obj.sim_id, 2) == 0
            [data1, data2] = sim_circulant_embedding( obj.N, obj.M,...
                                                        N2, M2, cov );
%                 obj.saved_simulation = data2;
%             else
%                 data1 = obj.saved_simulation;
%             end
            disp(size(data1));
            generator.turnOff();
            sample = Sample(obj);
            sample.set_values(data1(:));
            %We return a SampleOnSubGrid. This allows to have the
            %information of what points of the rectangular grid (here all
            %but in general this might not be the case) were randomly
            %generated.
            sample = SampleOnSubGrid(sample);
        end
        
        function fourier_grid = get_fourier_grid(obj)
            %Returns the corresponding Fourier grid
            %TODO This should adapt to changes in N and M
            if isempty(obj.fourier_grid)
                obj.fourier_grid = FourierGrid(obj);
            end
            fourier_grid = obj.fourier_grid;
        end
    end
    
    methods
        function h = plot_values_on_grid(obj, data, varargin)
           nargs = size(varargin);
           nargs = nargs(2);
           switch nargs
               case 0
                   new_fig = true;
                   plot_title = obj.getName();
                   grouped = false;
               case 1
                   plot_title = obj.getName();
                   grouped = false;
                   new_fig = varargin{1};
               case 2
                   grouped = false;
                   new_fig = varargin{1};
                   plot_title = varargin{2};
               case 3
                   new_fig = varargin{1};
                   plot_title = varargin{2};
                   group = varargin{3};
                   grouped = true;
           end
           if new_fig
               h = figure;
           else
               h = 0;
           end
           data = obj.values_to_matrix_form(data);
           ticks = obj.get_ticks();
           [X,Y] = meshgrid(ticks{1}, ticks{2});
           X= X';
           Y = Y';%TODO check why we need to transpose
           %             surf(X, Y, data)
           %             colorbar()
           %             title(fig_name)
           % %             hold on
           if grouped
               imagesc_(X(1:end,1),Y(1,1:end), data, group);
           else
               imagesc(X(1:end,1),Y(1,1:end), data);
           end
           colorbar();
           title(plot_title);
           axis('tight');
        end
    end
    
    methods
        function shift(obj, vector)
            %Shifts the grid by a given vector.
            obj.origins = obj.origins + vector;
        end
        
        %Operators overloading
        function test = isequal(obj, rect_grid_2)
            test = true;
            return;
            test = true;
            if obj.shape ~= rect_grid_2.shape
                test = false;
            end
            if obj.deltas ~= rect_grid_2.deltas
                test = false;
            end
            if obj.origins ~= rect_grid_2.origins
                test = false;
            end
        end
    end
    
    methods
        function [lags_X, lags_Y] = get_positive_lags_grid(obj)
            %TODO: obsolete
            N = obj.shape(1);
            M = obj.shape(2);
            delta_x = obj.deltas(1);
            delta_y = obj.deltas(2);
            lags_x = (0:N-1) * delta_x;
            lags_y = (0:M-1) * delta_y;
            [lags_X, lags_Y] = meshgrid(lags_x, lags_y);
            lags_X = lags_X';
            lags_Y = lags_Y';
        end
        
        function [lags_X, lags_Y] = get_negative_lags_grid(obj)
            [lags_X, lags_Y] = obj.get_positive_lags_grid();
            lags_X = -lags_X;
        end
        
        function [lags_X, lags_Y] = get_lags_grid(obj)
            %In the case of a rectangular grid the lags are easy to obtain.
            %Also note that the shape of the matrix returned is different
            %to the case of a general Grid.
            lags_x = (-(obj.N-1):obj.N-1) * obj.delta_x;
            lags_y = (-(obj.M-1):obj.M-1) * obj.delta_y;
            [lags_X, lags_Y] = meshgrid(lags_x, lags_y);
            lags_X = lags_X';
            lags_Y = lags_Y';
        end
        
        function [lags_X, lags_Y] = get_lags_grid_(obj, start_, end_)
            %Same as above but we can choose the start and end (in terms of
            %number of steps)
            disp('test');
            start_x = start_(1);
            start_y = start_(2);
            end_x = end_(1);
            end_y = end_(2);
            lags_x = (start_x : end_x) * obj.delta_x;
            lags_y = (start_y : end_y) * obj.delta_y;
            [lags_X, lags_Y] = meshgrid(lags_x, lags_y);
            lags_X = lags_X';
            lags_Y = lags_Y';   
        end
    end
end

