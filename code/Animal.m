classdef (Abstract) Animal < handle
    properties (Abstract)
        position
    end
    methods (Abstract)
       updatePosition(obj,positions)
    end
end
