classdef BernouilliMissingSample < RandomlyMissingSample
    %UNTITLED13 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = BernouilliMissingSample(sample, params)
            obj@RandomlyMissingSample(sample, params);
        end
        
        function r_mask = generate_random_mask(obj)
            r_mask = rand(obj.grid.get_nb_points(),1);
            r_mask = r_mask < obj.missingness_params(1);
        end
    end
    
end

