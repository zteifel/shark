classdef (Abstract) Animal < handle
    properties (Abstract)
        position
        tankSize
    end
    methods (Abstract)
       updatePosition(obj,positions)
    end
end
