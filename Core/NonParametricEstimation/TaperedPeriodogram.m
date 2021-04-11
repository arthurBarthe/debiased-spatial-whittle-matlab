classdef TaperedPeriodogram < Periodogram
    %This class implements the periodogram applied to tapered data. On
    %creating an instance of this class, a periodogram must 
    
    properties (Access = private)
        taper
    end
    
    methods (Access = public)
        function obj = TaperedPeriodogram(periodogram, taper)
            obj@Periodogram('Tapered periodogram')
            obj.taper = taper;
        end
        
        function est = compute(obj, sample)
            %We need to overwrite the compute method of the class
            %Periodogram. 
            %We first get the tapered version of the passed sample and
            %then use the compute method of the superclass on this new
            %sample.
            tapered_sample = obj.taper.apply(sample);
            est = compute@Periodogram(obj, tapered_sample);
        end
        
        function [kernel1, kernel2] = get_kernels(obj, grid)
            assert(isa(grid, 'SubGrid'));
            sample = SampleOnSubGrid(Sample(grid));
            %TODO below should be changed to 
            % modulation_sample = obj.taper.get_modulation_sample(grid);
            modulation_sample_ = obj.taper.get_modulation_sample(sample);
            modulation_sample_ = modulation_sample_.missing_values_to_zero();
            modulation_sample_ = modulation_sample_ .* grid.get_mask_new();
            modulation_sample = ModulationSample(grid.grid);
            modulation_sample.set_values(modulation_sample_.values());
            [kernel1, kernel2] = modulation_sample.get_kernels();
        end
    end
    
end

