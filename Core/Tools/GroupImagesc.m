classdef GroupImagesc < GroupGraphs
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        filter
        lower_bound
        upper_bound
        centered
    end
    
    methods
        function obj = GroupImagesc(filter)
            switch nargin
                case 0
                    obj.filter = [];
                case 1
                    obj.filter = filter;
            end
            obj.lower_bound = -Inf;
            obj.upper_bound = +Inf;
            obj.centered = false;
        end
        
        function setLowerBound(obj, value)
            obj.lower_bound = value;
        end
        
        function set_centered(obj, value)
            obj.centered = value;
        end
        
        function [min_data, max_data] = get_min_max(obj, graph)
            if isempty(obj.filter)
                data = graph.CData;
            else
                data = graph.CData(obj.filter(graph.CData));
            end
            min_data = max(min(data(:)), obj.lower_bound);
            max_data = min(max(data(:)), obj.upper_bound);
        end
        
        function update_graphs_(obj)
            if obj.centered
                min_ = -max(abs(obj.min_value), abs(obj.max_value));
                max_ = max(abs(obj.min_value), abs(obj.max_value));
            else
                min_ = obj.min_value;
                max_ = obj.max_value;
            end
            for i_graph = 1 : obj.nb_graphs
                h = obj.list_of_graphs{i_graph};
                if isvalid(h)
                    h.Parent.CLim = [min_ max_];
                end
            end
        end
        
        function create_listener_on_graph(obj, graph)
        end
    end
end

