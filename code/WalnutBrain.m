classdef WalnutBrain < Brain
    properties 
        turnRate = 0.3;
        speed = 3;
        prevDirection
    end
    methods
        function obj = WalnutBrain()    
            obj.prevDirection = randi(3); 
        end
        function [velocity, direction] = getMovement(obj,input)
            if rand < obj.turnRate
                direction = 1-2*(randi(2)-1);
            else
                direction = 0,
            end
            velocity = obj.speed;
        end
    end

end
