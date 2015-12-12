classdef Fish < handle
    
    properties
        
        position;
        velocity;
        tankSize;
        scareDistance = 5;
        maxSpeed = 3;
        positionReal;
        velocityReal;
        alive = 1;
        
    end
    
    methods
        
        function obj = Fish(position,velocity,tankSize,maxSpeed)
            if (nargin > 0)
                obj.position = round(position);
                obj.velocity = round(velocity);
                obj.tankSize = tankSize;
                obj.positionReal = position;
                obj.velocityReal = velocity;
                obj.maxSpeed = maxSpeed;
                
            end
        end
        
        
        function obj = updatePosition(obj,velocity,predatorPosition)
            
            obj.velocityReal = velocity;
            
            if (nargin > 2)
                obj.predatorFlee(predatorPosition);
                speed = norm(obj.velocityReal);
                if (speed > obj.maxSpeed)
                    obj.velocityReal = obj.maxSpeed*obj.velocityReal./speed;
                end
            end
            
            pos = obj.positionReal + obj.velocityReal;
            for i=1:2
                if pos(i) > obj.tankSize
                    pos(i) = pos(i) - obj.tankSize;
                elseif pos(i) < 0
                    pos(i) = pos(i) + obj.tankSize;
                end
            end
            obj.positionReal = pos;
            obj.position = round(pos);
            obj.velocity = round(velocity);
        end
        
        function obj = predatorFlee(obj,predatorPosition)
            
            predatorDistanceX = predatorPosition(1) - obj.positionReal(1);
            if (predatorDistanceX < -obj.tankSize/2)
                predatorDistanceX = predatorPosition(1) - ...
                    (obj.positionReal(1) - obj.tankSize);
            elseif (predatorDistanceX > obj.tankSize/2)
                predatorDistanceX = predatorPosition(1) - ...
                    (obj.positionReal(1) + obj.tankSize);
            end
            
            predatorDistanceY = predatorPosition(2) - obj.positionReal(2);
            if (predatorDistanceY < -obj.tankSize/2)
                predatorDistanceY = predatorPosition(2) - ...
                    (obj.positionReal(2) - obj.tankSize);
            elseif (predatorDistanceY > obj.tankSize/2)
                predatorDistanceY = predatorPosition(2) - ...
                    (obj.positionReal(2) + obj.tankSize);
            end
            
            if (norm([predatorDistanceX predatorDistanceY]) < obj.scareDistance)
                
                obj.velocityReal(1) = obj.velocityReal(1) - ...
                    (predatorPosition(1) - obj.positionReal(1))/3;
                
                obj.velocity(2) = obj.velocity(2) - ...
                    (predatorPosition(2) - obj.positionReal(2))/3;
                
            end
        end
        
        
    end
    
end