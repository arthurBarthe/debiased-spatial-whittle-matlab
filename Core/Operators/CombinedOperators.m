classdef CombinedOperators < SampleOperator
    %This class define the structure for an operator that is the
    %combination of several operators. Not used directly by users in
    %practice, as one can write:
    %op = op1 + op2
    %which will create a new op that will apply op1 to a sample, and then
    %will apply op2 to the result of this operation.
    
    properties
        operator1
        operator2
    end
    
    methods
        function obj = CombinedOperators(op1, op2)
            obj@SampleOperator([op2.name '( ' op1.name ' )']);
            obj.operator1 = op1;
            obj.operator2 = op2;
        end
        
        function new_sample = apply(obj, sample)
            new_sample = obj.apply_(sample);
        end
        
        function new_model = get_new_model(obj, model, sample)
            %TODO ...
            new_model1 = obj.operator1.get_new_model(model, sample);
            new_model = obj.operator2.get_new_model(new_model1, sample);
        end
    end
    
    methods (Access = protected)
        function new_sample = apply_(obj, sample)
            new_sample1 = obj.operator1.apply(sample);
            new_sample = obj.operator2.apply(new_sample1);
        end
    end
end

