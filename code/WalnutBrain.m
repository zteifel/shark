classdef WalnutBrain < Brain

    properties 
        turnRate 
        speed
        prevDirection
    end

    methods
        function obj = WalnutBrain(speed,turnRate)    
            obj.turnRate = turnRate;
            obj.prevDirection = randi(3)-2; 
            obj.speed = speed
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
