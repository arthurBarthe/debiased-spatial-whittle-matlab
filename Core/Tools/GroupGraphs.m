classdef GroupGraphs < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nb_graphs
        list_of_graphs
        min_value
        max_value
        updating_graphs
    end
    
    methods (Abstract)
        [min,max] = get_min_max(obj, graph);
        update_graphs_(obj);
    end
    
    methods
        function obj = GroupGraphs()
            obj.list_of_graphs = {};
            obj.nb_graphs = 0;
            obj.min_value = +inf;
            obj.max_value = -inf;
            obj.updating_graphs = false;
        end
        
        function add(obj, graph)
            %Adds the graph to the group and updates other graphs if
            %needed.
            %Adds the graph to the list
            obj.nb_graphs = obj.nb_graphs + 1;
            obj.list_of_graphs{obj.nb_graphs} = graph;
            %Updates the min and max values
            [min_data, max_data] = obj.get_min_max(graph);
            obj.update_min_max(min_data, max_data);
            obj.update_graphs();
            obj.create_listener_on_graph(graph);    
        end
        
        function delete(obj)
            for i = 1 : obj.nb_graphs
                obj.list_of_graphs{i}.delete();
            end
        end
    end
    
    methods (Access = protected)
        function update_min_max(obj, min_data, max_data)
            if min_data < obj.min_value
                obj.min_value = min_data;
            end
            if max_data > obj.max_value
                obj.max_value = max_data;
            end
        end
        
        function update_graphs(obj)
            obj.updating_graphs = true;
            obj.update_graphs_();
            obj.updating_graphs = false;
        end
    end
end

