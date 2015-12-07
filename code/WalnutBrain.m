classdef WalnutBrain < Brain

    properties 
        turnRate = 0.3;
        speed
        prevDirection
    end

    methods
        function obj = WalnutBrain()    
            obj.prevDirection = randi(3); 
            obj.speed = round(obj.maxspeed/4)
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
