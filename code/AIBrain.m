classdef AIBrain < Brain

    methods

        function [velocity, direction] = getMovement(obj,inputs)
            if inputs(3) ~= 0
              velocity = inputs(3);
              direction = inputs(6);
            elseif inputs(1) ~= 0
              velocity = inputs(1);
              direction = inputs(4);
            else
              velocity = inputs(2);
              direction = inputs(5);
            end
        end
    end

end
