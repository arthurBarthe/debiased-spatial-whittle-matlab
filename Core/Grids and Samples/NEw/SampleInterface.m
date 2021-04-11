classdef SampleInterface < handle
    %This abstract class define a sample, which must be able to return a
    %grid and a list of values
    
    properties
        grid
    end
    
    methods (Abstract)
        values = get_values(obj);
        sample = plus(sample1, sample2);
        sample = minus(sample1, sample2);
        sample = times(sample1, sample2);
    end
    
end

