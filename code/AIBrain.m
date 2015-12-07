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
        function [velocity, direction] = getMovement(obj,inputs,beta)
            squash = @(x) 1./(1+exp(-beta.*x));
            
            for i=1:length(weights)
                inputs = squash(weights{i}*[inputs; 1]);
            end
            outputs = inputs;
            velocity = floor(outputs(1)*obj.maxspeed)+1;
            direction = floor(outputs(2)*3)-1; 
        end
    end

end
