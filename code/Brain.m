classdef (Abstract) Brain
    properties
        maxspeed 
    end
    methods (Abstract)
       getMovement(obj,input)
    end
end
