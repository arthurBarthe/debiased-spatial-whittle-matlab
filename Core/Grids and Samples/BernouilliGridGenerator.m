classdef BernouilliGridGenerator < GridGenerator
    %This class defines the structure for an object that generates grids
    %based on a given grid, where points of the grid are randomly missing
    %according to Bernouilli i.i.d. variables.
    %Properties
    %base_grid Grid base grid used to generate the grids
    %random_generator RandomGenerator For the generation of random numbers
    %p
    
    properties
        base_grid
        random_generator
        p
    end
    
    methods
        function obj = BernouilliGridGenerator(base_grid, ...
                random_generator, p)
            obj.base_grid = base_grid;
            obj.p = p;
            obj.random_generator = random_generator;
        end
        
        function grid = generate_grid(obj)
            nb_points = obj.base_grid.get_nb_points();
            obj.random_generator.turnOn();
            temp = rand(nb_points, 1);
            obj.random_generator.turnOff();
            random_mask = temp <= obj.p;
            grid = SubGrid(obj.base_grid, random_mask);
        end
    end
    
end

