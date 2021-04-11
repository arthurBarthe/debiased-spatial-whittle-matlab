classdef UniformGrid < Grid
    %This class implements a grid where the locations are obtained
    %according to a uniform sampling
    
    properties
    end
    
    methods
        function obj = UniformGrid(size_X, size_Y)
            obj@Grid(size_X, size_Y);
        end
        
        function generate_points(obj, n_points)
            x_s = rand(n_points, 1) * obj.size_X;
            y_s = rand(n_points, 1) * obj.size_Y;
            obj.points = [x_s y_s];
        end
    end
    
end

