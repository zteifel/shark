classdef WalnutBrain < Brain

    properties 
        turnRate 
        prevDirection
        speed
    end

    methods
        function obj = WalnutBrain(speed,turnRate)    
            obj.turnRate = turnRate;
            obj.prevDirection = randi(3)-2; 
            obj.speed = speed
        end
        function [obj.speed, direction] = getMovement(obj,input)
            if rand < obj.turnRate
                direction = rand; 
            end
            
        end
    end

end
