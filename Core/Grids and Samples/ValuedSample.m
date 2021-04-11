classdef ValuedSample < Sample
    %This class inherits from the class Sample. It represents a Sample with
    %some values. 
    
    properties
        values      %Double[Nx1]Values over the grid of the sample. Note 
                    %that the actual values of the sample are a subset of
                    %these values obtained using the mask property of
                    %Sample.
    end
    
    methods
        function obj = ValuedSample(sample, values)
            %The constructor for this class takes a sample as an argument,
            %as well as values.
            obj@Sample(sample.grid, sample.mask());
            %We set the values. Important here to use the set method which
            %ensures that the passed values array has the right dimensions.
            obj.setValues(values);
        end
        
        function values = get_values(obj)
            %Note that this only returned the values according to the mask,
            %not the whole vector of values!
            %Returns
            %values     Double[Mx1]     The values of the sample, according
            %                           to the sample mask.
            values = obj.values(logical(obj.mask));
        end
        
        function setValues(obj, values)
            [shape1,shape2] = size(values);
            assert(shape2 == 1 && shape1 == obj.get_nb_observations());
            obj.values = values;
        end
        
        function cov_mat = get_sample_covariance_matrix(obj)
            %This method returns the sample covariance matrix. Used for
            %instance by the exact likelihood estimator.
            cov_mat = obj.get_values() * obj.get_values()';
        end
        
        function sample = missing_values_to_zero(obj)
            sample = Sample(obj.grid);
            values_complete = zeros(obj.grid.get_nb_points(), 1);
            values_complete(obj.mask) = obj.values;
            sample = ValuedSample(sample, values_complete);
        end
        
        function h = plot(obj, fig_name, group)
            %We call the method from the grid, as we may choose to use
            %different ways to plot the data depending on the type of the
            %grid.
            switch nargin
                case 1
                    fig_name = obj.getName();
            end
            h = obj.grid.plot_values_on_grid(obj.values, obj.mask, fig_name);
        end
        
        function plot_periodogram(obj, group_graphs)
            switch nargin
                case 1
                    group = false;
                case 2
                    group = true;
            end
            P = Periodogram();
            if group
                P.plot(obj, group_graphs);
            else
                P.plot(obj);
            end
        end
        
        function plot_tapered_periodogram(obj, group_graphs)
            switch nargin
                case 1
                    group = false;
                case 2
                    group = true;
            end
            P = Periodogram();
            taper = Taper(@hanning, 'Hanning');
            tapered_P = TaperedPeriodogram(P, taper);
            if group
                tapered_P.plot(obj, group_graphs);
            else
                tapered_P.plot(obj);
            end
        end
    end
    
    methods
        function sum =  plus(obj, obj2)
            %Returns the sum of two samples
            if isa(obj2, 'ValuedSample')
                assert(obj.grid == obj2.grid);
                sum = ValuedSample(obj, obj.values + obj2.values);
            elseif isa(obj2, 'numeric')
                sum = ValuedSample(obj, obj.values + obj2);
            end
        end
        
        function diff = minus(obj, obj2)
            if isa(obj2, 'ValuedSample')
                assert(obj.grid == obj2.grid);
                %Returns the difference of two samples
                %Returns the sum of two samples
                diff = ValuedSample(obj, obj.values - obj2.values);
            elseif isa(obj2, 'numeric')
                diff = ValuedSample(obj, obj.values - obj2);
            end
        end
        
        function div = rdivide(obj, obj2)
            if isa(obj2, 'ValuedSample')
                assert(obj.grid == obj2.grid);
                grid = obj.grid;
                new_values = zeros(grid.N, grid.M);
                new_mask = obj.mask & obj2.mask;
                new_values(obj.new_mask) = obj1.values(obj.new_mask) ./ ...
                    obj2.values(obj.new_mask);
                new_sample = Sample(grid, new_mask);
                div = ValuedSample(new_sample, new_values);
            elseif isa(obj2, 'numeric')
                assert(obj2 ~= 0);
                div = ValuedSample(obj, obj.values / obj2);
            end
        end
        
        function div = mrdivide(obj, obj2)
            div = obj.rdivide(obj, obj2);
        end
    end
end

