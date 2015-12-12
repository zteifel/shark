classdef AIBrain < Brain

    properties
        weights % Cell array with weights for all layers in 2D array
        beta
    end

    methods
        function obj = AIBrain(weights, beta)
            obj.weights = weights;
            obj.beta = beta;
        end
        function [velocity, direction] = getMovement(obj,inputs)
            squash = @(x) 1./(1+exp(-obj.beta.*x));
            inputs = [inputs; 1];
            for i=1:length(obj.weights)
                inputs = squash(obj.weights{i}*inputs);
            end
            velocity = inputs(1);
            direction = inputs(2);
        end
    end

end
