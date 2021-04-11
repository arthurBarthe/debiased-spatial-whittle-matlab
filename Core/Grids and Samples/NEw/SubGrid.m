classdef SubGrid < Grid
    %This class defines the structure of a grid which is a subgrid of
    %another grid, by defining a mask over the points of the initial grid.
    
    properties
        grid
        mask
        mask_modulation
    end
    
    methods
        function obj = SubGrid(varargin)
            obj@Grid();
            switch nargin
                case 0
                    grid = RectangularGrid.empty();
                case 1
                    obj.grid = varargin{1};
                    mask = ones(obj.grid.get_nb_points(), 1);
                    obj.set_mask(mask);
                case 2
                    obj.grid = varargin{1};
                    mask = varargin{2};
                    obj.set_mask(mask);
            end
        end
        
        function points = get_points(obj)
            %Returns the points of the grid. 
            points = obj.grid.get_points();
            points = points(obj.mask, :);
        end
        
        function set_base_grid(obj, grid)
            if isempty(obj.grid)
                obj.grid = grid;
                mask_ = ones(obj.grid.get_nb_points(), 1);
                obj.set_mask(mask_);
            else
                error('The base grid cannot be changed.');
            end
        end
        
        function nb_points = get_nb_points(obj)
            nb_points = sum(obj.mask);
        end
        
        function g = get_complete_grid(obj)
            g = obj.grid;
        end
        
        function set_mask(obj, mask)
            %TODO add checks on dimensions of mask.
            obj.mask = logical(mask);
            obj.get_mask_new();
        end
        
        function mask = get_mask(obj)
            mask = obj.mask_modulation;
        end
        
        function mask = get_mask_new(obj)
            mask = ModulationSample(obj.grid);
            mask.set_values(obj.mask);
            obj.mask_modulation = mask;
        end
        
        function subgrid = complementary_grid(obj)
            %returns the complementary grid of this grid
            subgrid = SubGrid(obj.grid, ~obj.mask);
        end
        
        function subRectGrid = cast2subRect(obj)
            subRectGrid = SubRectangularGrid(obj.grid, obj.mask);
        end
        
        function covariances_sample = get_covariances_sample(obj, model)
            %Redefines the inherited function.
            covariances_sample = get_covariances_sample@Grid(model);
            covariances_sample = SampleOnSubGrid(...
                covariances_sample);
        end
    end
    
    methods
        %Operators overloading. Union, intersection of subgrids
        function subgrid = plus(obj, subgrid2)
            %Union of two subgrids
            assert(obj.grid == subgrid2.grid);
            mask1 = obj.mask;
            mask2 = subgrid2.get_mask();
            new_mask = mask1 | mask2;
            subgrid = SubGrid(obj.grid, new_mask);
        end
        
        function subgrid = times(obj, subgrid2)
            %Intersection
            assert(obj.grid == subgrid2.grid);
            mask1 = obj.mask;
            mask2 = subgrid2.get_mask();
            new_mask = mask1 & mask2;
            subgrid = SubGrid(obj.grid, new_mask);
        end
        
        function test = isequal(obj, subgrid_2)
            test = isequal(obj.grid, subgrid_2.grid);
            test = test && isequal(obj.mask, subgrid_2.mask);
        end
    end
    
    methods
        function sample = simulate(obj, model, generator)
            complete_sample = obj.grid.simulate(model, generator);
            sample = SampleOnSubGrid(Sample(obj));
            values = complete_sample.get_values();
            values = values(obj.mask);
            sample.set_values(values);
        end
    end
    
    methods
        function h = plot_values_on_grid(obj, values, fig_name)
            error('Convert to full sample before plotting!');
        end
    end
end

