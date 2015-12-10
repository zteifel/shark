classdef Fish < handle
    
    properties
        
        position;
        velocity;
        tankSize;
        scareDistance = 10;
        maxSpeed = 2;
        
    end
    
    methods
        
        function obj = Fish(position,velocity,tankSize)
            if (nargin > 0)
                obj.position = position;
                obj.velocity = velocity;
                obj.tankSize = tankSize;
            end
        end
        
        
        function obj = updatePosition(obj,velocity,predatorPosition)
            
            obj.velocity = velocity;
            
            if (nargin > 2)
                predatorFlee(predatorPosition);
                speed = norm(obj.velocity);
                if (speed > obj.maxSpeed)
                    obj.velocity = obj.maxSpeed*obj.velocity./speed;
                end
            end
            
            pos = obj.position + velocity;
            for i=1:2
                if pos(i) > obj.tankSize
                    pos(i) = pos(i) - obj.tankSize;
                elseif pos(i) < 0
                    pos(i) = pos(i) + obj.tankSize;
                end
            end
            obj.position = pos;
        end
        
        function obj = predatorFlee(obj,predatorPosition)
            
            predatorDistanceX = predatorPosition(1) - obj.position(1);
            if (predatorDistanceX < -obj.tankSize/2)
                predatorDistanceX = predatorPosition(1) - ...
                    (obj.position(1) - obj.tankSize);
            elseif (predatorDistanceX > obj.tankSize/2)
                predatorDistanceX = predatorPosition(1) - ...
                    (obj.position(1) + obj.tankSize);
            end
            
            predatorDistanceY = predatorPosition(2) - obj.position(2);
            if (predatorDistanceY < -obj.tankSize/2)
                predatorDistanceY = predatorPosition(2) - ...
                    (obj.position(2) - obj.tankSize);
            elseif (predatorDistanceY > obj.tankSize/2)
                predatorDistanceY = predatorPosition(2) - ...
                    (obj.position(2) + obj.tankSize);
            end
            
            if (norm([predatorDistanceX predatorDistanceY]) < obj.scareDistance)
                
                obj.velocity(1) = obj.velocity(1) - ...
                    (predatorPosition(1) - obj.position(1))/10;
                
                obj.velocity(2) = obj.velocity(2) - ...
                    (predatorPosition(2) - obj.position(2))/10;
                
            end
        end
        
        
    end
    
end