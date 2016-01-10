classdef AIBrain < Brain

  properties
    moveAngle;
  end

  methods

    function obj = AIBrain(moveAngle);
      obj.moveAngle = moveAngle*2;
    end

    function [velocity, direction] = getMovement(obj,inputs)
      if inputs(3) ~= 0
        velocity = inputs(3);
        direction = inputs(6);
      elseif inputs(1) ~= 0
        if inputs(4)*pi < pi/2-obj.moveAngle/2
          direction = 0;
          velocity = 0.2;
        elseif inputs(4)*pi > pi/2+obj.moveAngle/2
          direction = 1;
          velocity = 0.2;
        else
          velocity = inputs(1);
          direction = inputs(4);
        end
      else
        direction = 0;
        velocity = 0.2;
      end
    end
  end

end
