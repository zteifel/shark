classdef StupidFish < Animal

  properties

    position
    velocity
    tankSize

  end

  methods

    function obj = StupidFish(position,velocity,tankSize)
        obj.position = position;
        obj.velocity = velocity;
        obj.tankSize = tankSize;
    end

    function position =  updatePosition(obj,positions);
      positon = positon + velocity;
      for i=1:2
        if position(i) > tanksize
          position(i) = position(i) - obj.tankSize;
        elseif position(i) < 0 
          position(i) = position(i) + obj.tankSize;
        end
      end
      obj.position = position;
    end  

  end

end  
