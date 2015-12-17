classdef Fish < handle
    
    properties
        
        position;
        velocity;
        tankSize;
        scareDistance = 8;
        maxSpeed = 3;
        positionReal;
        velocityReal;
        
    end
    
    methods
        
        function obj = Fish(position,velocity,tankSize,scareDistance,maxSpeed)
            if (nargin > 0)
                obj.position = round(position);
                if (obj.position(1) == 0)
                    obj.position(1) = 1;
                end
                if (obj.position(2) == 0)
                    obj.position(2) = 1;
                end
                obj.velocity = round(velocity);
                obj.tankSize = tankSize;
                obj.scareDistance = scareDistance;
                obj.maxSpeed = maxSpeed;
                obj.positionReal = position;
                obj.velocityReal = velocity;
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
            if (obj.position(1) == 0)
                obj.position(1) = 1;
            end
            if (obj.position(2) == 0)
                obj.position(2) = 1;
            end
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
                    (predatorPosition(1) - obj.positionReal(1))/2;
                
                obj.velocity(2) = obj.velocity(2) - ...
                    (predatorPosition(2) - obj.positionReal(2))/2;
                
            end
        end
        
        
    end
    
end