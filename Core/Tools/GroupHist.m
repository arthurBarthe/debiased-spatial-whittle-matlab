classdef GroupHist < GroupGraphs
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function [min_data, max_data] = get_min_max(obj, graph)
            axes = graph.Parent;
            lims = axes.XLim;
            min_data = lims(1);
            max_data = lims(2);
        end
        
        function update_graphs_(obj)
            for i_graph = 1 : obj.nb_graphs
                h = obj.list_of_graphs{i_graph};
                if isvalid(h)
                    h.Parent.XLim = [obj.min_value obj.max_value];
                end
            end
        end
        
        function updated(obj, src, event)
            if ~obj.updating_graphs
                axes = event.AffectedObject;
                xlim = axes.XLim;
                obj.min_value = xlim(1);
                obj.max_value = xlim(2);
                obj.update_graphs();
            end
        end
        
        function create_listener_on_graph(obj, graph)
            axes = graph.Parent;
            addlistener(axes, 'XLim', 'PostSet', @obj.updated);
        end
    end
end

