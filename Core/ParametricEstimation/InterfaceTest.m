classdef InterfaceTest < handle
    %This class defines an interface for tests of estimators. Usually a
    %test will store estimates and will have a fixed number of samples for
    %each configuration. It will also have a results_folder where the
    %results might be saved.
    
    properties 
        nb_samples
        estimates
        results_folder
    end
    
    methods (Abstract)
        run(obj)
        plot(obj, save_figs, format_fig)
        summary(obj)
    end
    
    methods
        function set.nb_samples(obj, nb)
            %This method sets the number of independent samples that
            %will be used in the simulation/estimation step.
            obj.nb_samples = nb;
        end
        
        function setResults_folder(obj, folder)
            %TODO Check that the folder exists on the disk, if not create
            %it.
            obj.results_folder = folder;
        end
    end
    
    
end

