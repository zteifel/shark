classdef StupidFish < Animal

  properties

    position
    velocity
    tankSize
    maxSpeed
    alive = true;
    
  end

  methods

    function obj = StupidFish(position,velocity,maxSpeed,tankSize)
        obj.position = position;
        obj.velocity = velocity;
        obj.tankSize = tankSize;
        obj.maxSpeed = maxSpeed;
    end

    function position =  updatePosition(obj,positions);
      obj.position = obj.position + obj.velocity;
      for i=1:2
        if obj.position(i) > obj.tankSize
          obj.position(i) = obj.position(i) - obj.tankSize;
        elseif obj.position(i) <= 0 
          obj.position(i) = obj.position(i) + obj.tankSize;
        end
      end
      position = obj.position;
    end  

  end

end  
