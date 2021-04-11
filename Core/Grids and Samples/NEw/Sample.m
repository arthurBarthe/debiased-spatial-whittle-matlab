classdef Sample < SampleInterface
    %This class defines the structure of a basic sample where we just store
    %one value for each point of the corresponding grid. There can be
    %multiple samples defines for a single grid.
    
    properties
        values
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
    
    methods
        function obj = Sample(grid)
            c = obj.getCount();
            obj.grid = grid;
            obj.values = zeros(grid.get_nb_points(), 1);
            obj.name = ['Sample ' num2str(c)];
        end
        
        function name = getName(obj)
            name = obj.name;
        end
        
        function values = get_values(obj, mask)
            %Returns the list of values corresponding to the points
            %obtained when calling the grid's get_points method (same
            %order)
            switch nargin
                case 1
                    values = obj.values;
                case 2
                    assert(islogical(mask));
                    assert(length(mask) == length(obj.values));
                    values = obj.values(mask);
            end
        end
        
        function set_values(obj, values)
            error_message1 = ['The values passed to Sample.set_values ' ...
                'should be a column vector'];
            error_message2 = ['The number of values passed to '...
                'Sample.set_values() does not match the number of ' ...
                'points of the Sample''s grid'];
            assert(ismatrix(values));
            [nb_values, dim2] = size(values);
            assert(dim2 == 1, error_message1);
            assert(nb_values == obj.grid.get_nb_points(), error_message2);
            obj.values = values;
        end
        
        function setValues(obj, values)
            %TODO obsolete
            warning(['The setValues method of class Sample is obsolete' ...
                'and will be removed at some point. Use the method ' ...
                'set_values instead.']);
            obj.set_values(values);
        end
        
        function sample = new(obj)
            sample = Sample(obj.grid);
        end
        
        function fftshift(obj)
            %Performs a fftshift on the values
            %TODO Create a subclass FourierSample
            %TODO need to shift the grid too
            assert(isa(obj.grid, 'RectangularGrid'))
            values = obj.get_values();
            values = reshape(values, obj.grid.shape);
            values = fftshift(values);
            obj.set_values(values(:));
        end
        
        function ifftshift(obj)
            %Performs a ifftshift on the values
            %TODO Create a subclass FourierSample
            %TODO need to shift the grid too
            assert(isa(obj.grid, 'RectangularGrid'))
            values = obj.get_values();
            values = reshape(values, obj.grid.shape);
            values = ifftshift(values);
            obj.set_values(values(:));
        end
        
        %Operators overloading---------------------------------------------
        function sample = plus(sample1, sample2)
            %Addition: s = s1 + s2 or s = s1 + c
            sample = Sample(sample1.grid);
            if isa(sample2, 'numeric')
                sample.set_values(sample1.get_values() + sample2);
            else
                assert(isequal(sample1.grid,sample2.grid));
                sample.set_values(sample1.get_values() + sample2.get_values());
            end
        end
        
        function sample = minus(sample1, sample2)
            %Substraction: s = s1 - s2 or s = s1 - c
            sample = Sample(sample1.grid);
            if isa(sample2, 'numeric')
                sample.set_values(sample1.get_values() - sample2);
            else
                assert(isequal(sample1.grid, sample2.grid));
                sample.set_values(sample1.get_values() - sample2.get_values());
            end
        end
        
        function sample = uminus(obj)
            %negative: s = -s1
            sample = Sample(obj.grid);
            sample.set_values(-obj.get_values());
        end
        
        function sample = times(sample1, sample2)
            assert(isequal(sample1.grid,sample2.grid));
            sample = Sample(sample1.grid);
            sample.set_values(sample1.get_values() .* sample2.get_values());
        end
        
        function sample = mtimes(sample1, scalar_value)
            sample = Sample(sample1.grid);
            sample.set_values(scalar_value * sample1.get_values());
        end
        
        function sample = rdivide(sample1, sample2)
            %sample1 ./ sample2
            assert(isequal(sample1.grid, sample2.grid));
            sample = Sample(sample1.grid);
            sample.set_values(sample1.get_values() ./ sample2.get_values());
        end
        
        function sample = mrdivide(sample1, scalar_value)
            %sample1 / scalar
            sample = Sample(sample1.grid);
            sample.set_values(sample1.get_values() / scalar_value);
        end
        
        function sample = lt(sample1, sample2)
            assert(sample1.grid == sample2.grid);
            sample = Sample(sample1.grid);
            sample.set_values(sample1.get_values() < sample2.get_values());
        end
        
        function sample = le(sample1, sample2)
            assert(sample1.grid == sample2.grid);
            sample = Sample(sample1.grid);
            sample.set_values(sample1.get_values() <= sample2.get_values());
        end
        
        function sample = power(obj, p)
            sample = Sample(obj.grid);
            values_2 = obj.values .^ p;
            sample.set_values(values_2);
        end
        
        function sample = subsample(obj, subgrid)
            %Returns a subsampled version of the sample, where subgrid must
            %be a subgrid of the grid on which the sample is defined
            %
            %Args:
            %subgrid: SubGrid
            assert(isequal(subgrid.grid, obj.grid));
            sample = Sample(subgrid);
            sample = SampleOnSubGrid(sample);
            complete_values = obj.get_values();
            sample.set_values(complete_values(subgrid.mask));
        end
    end
    
    methods
        function cov_mat = get_sample_covariance_matrix(obj)
            %This method returns the sample covariance matrix. Used for
            %instance by the exact likelihood estimator.
            cov_mat = obj.get_values() * obj.get_values()';
        end
    end
    
    methods
        function h = plot(obj, varargin)
            %Plots the sample. All args are optional.
            %Args:
            %new_fig: boolean, true if a new figure is created
            %title: string, title of the plot
            %group: GroupImagesc
            h = obj.grid.plot_values_on_grid(obj.values, varargin{1:end});
            set(gca,'YDir','normal')
        end
    end
end

