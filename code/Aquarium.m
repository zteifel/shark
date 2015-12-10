classdef Aquarium 
    
  properties
    inhabitants
    positions
    tankSize
    fishEaten = 0;
  end

  methods
    function obj = Aquarium(shark_conts, tank_consts, fish_consts, weights, beta);
      obj.positions = zeros(tank_consts.tankSize);
      % Create shark
      shark_consts.position = randi(tank_consts.tankSize, 1, 2);
      shark_consts.tankSize = tank_consts.tankSize; 
      obj.inhabitants{1} = Shark(shark_consts, weights, beta);
      obj.positions(shark_consts.position) = 1;
      % Create fish shoal
      fishVelocity = randi(fish_const.maxSpeed,1,2).*(1-2*(randi(2,1,2)-1));
      while norm(fishVelocity) > fish_consts.maxSpeed
        fishVelocity = randi(fish_const.maxSpeed,1,2).*(1-2*(randi(2,1,2)-1));
      end
      for i=2:tank_consts.nrOfFish+1
        pos = randi(tank_consts.tankSize,1,2);
        while obj.positions(pos) ~= 0
            pos = randi(tank_consts.tankSize,1,2);
        end
        obj.inhabitants{i} = StupidFish(pos,fishVelocity);
        obj.positions(pos) = i; 
      end
    end

    function fishEaten = run(obj)
      while obj.inhabitants{1}.hunting
        for i=1:length(obj.inhabitants)
          pos = obj.position;
          obj.pos(obj.inhabitants{i}.position) = 0;
          newPos = obj.inhabititans{i}.updatePosition(obj.positions);
          pos(newPos) = i;
          if i==1
            obj.positions(newPos) = 0; % Kill fish
          end
        end
        obj.positions = pos;
      end
      fishEaten = obj.inhabitants{1}.fishEaten;
    end 
  end

end
