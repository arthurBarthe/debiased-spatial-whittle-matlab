classdef SubsamplingOperator < SampleOperator
    %This class defines the structure to define subsampling operators over
    %samples over rectangular grids.
    
    properties
        pattern
        offset
    end
    
    methods
        function obj = SubsamplingOperator(name)
            switch nargin
                case 0
                    name = 'Subsampler';
            end
            obj@SampleOperator(name);
            obj.offset = [0 0];
        end
        
        function set_subsampling_pattern(obj, pattern_array, offset_)
            %Sets the subsapmling pattern, which should be a matrix. For
            %instance, if we want to sample of point out of two in each
            %direction, the matrix used should be
            %1 0 1 0
            %0 0 0 0
            %1 0 1 0
            %0 0 0 0
            %Note that for now you should pass a patern that makes the new
            %sample regular as well. Hence the following pattern does not
            %work (because it's not separable).
            %1 0 1 0
            %0 1 0 0
            %1 0 1 0
            %0 0 0 0
            switch nargin
                case 2
                    offset_ = [0 0];
            end
            obj.pattern = logical(pattern_array);
            obj.offset = offset_;
        end
        
        function new_model = get_new_model(obj, model, sample)
            %Returns the model of the data that is obtained after
            %subsampling.
            new_model = model;
        end
            
    end
    
    methods (Access = private)
        function [delta_x, delta_y] = new_deltas(obj, grid)
            %determines the new deltas
            temp = find(obj.pattern(1,:), 2); 
            delta_x = grid.delta_x * diff(temp);
            temp = find(obj.pattern(:,1), 2);
            delta_y = grid.delta_y * diff(temp);
        end
    end
    
    methods (Access = protected)
        function sample = apply_(obj, s)
            %Returns a subsampled ValuedSample instance based on the passed
            %ValuedSample instance s and on the sampling pattern.
            grid = s.grid;
            assert(grid.isRectangular());
            N = grid.N;
            M = grid.M;
            %We extend the pattern to the whole grid. We first compute the
            %number of times we need to extend the pattern in each
            %dimension.
            size_pattern = size(obj.pattern);
            nb_1 = ceil(N / size_pattern(1));
            nb_2 = ceil(M / size_pattern(2));
            extended_pattern = repmat(obj.pattern, nb_1, nb_2);
            offset_x = obj.offset(1);
            offset_y = obj.offset(2);
            [N_,M_] = size(extended_pattern);
            extended_pattern = [zeros(offset_x, M_); extended_pattern];
            [N_,M_] = size(extended_pattern);
            extended_pattern = [zeros(N_, offset_y) extended_pattern];
            extended_pattern = extended_pattern(1 : N, 1 : M);
            mask = s.mask;
            mask = grid.values_to_matrix_form(mask);
            extended_pattern_ = mask & extended_pattern;
            values_matrix = grid.values_to_matrix_form(s.values);
            new_values_mat = values_matrix(extended_pattern_);
            %Now we determnine the new mask.
            new_mask = mask(extended_pattern_);
            new_values = new_values_mat(:);
            new_mask = new_mask(:);
            [new_delta_x, new_delta_y] = obj.new_deltas(grid);
            new_N = sum(extended_pattern(1,:));
            new_M = sum(extended_pattern(:,1));
            new_grid = RectangularGrid(new_N, new_M, new_delta_x, ...
                new_delta_y);
            new_sample = Sample(new_grid, new_mask);
            sample = ValuedSample(new_sample, new_values);
        end
    end
        
    
end

