classdef (Abstract) Brain
    properties
        maxspeed = 20; 
    end
    methods (Abstract)
       getMovement(obj,input)
    end
end
