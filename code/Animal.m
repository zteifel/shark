classdef (Abstract) Animal 
    properties
        position
        tankSize
    end
    methods (Abstract)
       updatePosition(obj,positions)
    end
end
