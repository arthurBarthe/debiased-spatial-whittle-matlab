classdef SampleFromImage < Sample
    %This class allows to define a sample from a black and white image.
    
    properties
    end
    
    methods
        function obj = SampleFromImage(image_filename, grid)
            obj@Sample(grid);
            data = imread(image_filename);
            data = data(:,:,1) == 0;
            [height, width] = size(data);
            g_height = grid.size_Y; 
            g_width = grid.size_X;
            mask = ones(grid.get_nb_points(),1);
            for i = 1 : grid.get_nb_points()
                point = grid.points(i,:);
                mask(i) = data(1 +  round(point(2) / g_height * (height - 1)), ...
                    1 +  round(point(1) / g_width * (width - 1)));
            end
            obj.setMask(mask);
        end
    end
    
end

