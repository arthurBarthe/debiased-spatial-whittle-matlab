classdef RandomlyMissingSample < Sample
    %This class represents samples where the missingness is not defined
    %manually but instead where the missingness on the latent grid occurs
    %according to a random patter.
    %This class is an Abstract class. Classes implementing this class must
    %implement the method generate_random_mask.
    
    properties
        missingness_params
    end
    
    methods (Abstract)
        r_mask = generate_random_mask(params)
    end
    
    methods
        function obj = RandomlyMissingSample(sample, params)
            obj@Sample(sample.grid);
            obj.missingness_params = params;
            random_mask = obj.generate_random_mask();
            %We multiply the mask of the sample with the random mask, as
            %points initially missing in the initial sample must still be
            %missing in the new sample.
            obj.setMask(random_mask .* obj.getMask());
        end
    end
    
end

