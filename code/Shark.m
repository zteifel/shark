classdef Shark < Animal
  properties
    position
    direction
    observeDist
    tankSize
    brain
    maxSpeed 
    fishEatGoal
    energy = 0;
    maxEnergy
    moveAngle
    closeObserve
    hunting = true;
    fishEaten = 0;
  end

  methods
    function obj = Shark(consts,weights,beta);
        obj.position = consts.position;
        obj.observeDist = consts.observeDist;
        obj.tankSize = consts.tankSize;
        obj.maxSpeed = consts.maxSpeed;
        obj.fishEatGoal = consts.fishEatGoal;
        obj.maxEnergy = consts.maxEnergy;
        obj.moveAngle = consts.moveAngle*pi;
        obj.closeObserve = consts.closeObserve;
        dir = [0,0];
        while sum(abs(dir)) < 1
            dir = randi(3,1,2)-2;
        end 
        obj.direction = dir; 
        if length(weights) == 0
            obj.brain = WalnutBrain(0.5,0.5);
        else
            obj.brain = AIBrain(weights,beta);
        end 
    end

    function fishIndividuals = updatePosition(obj, fishIndividuals)
      tank = zeros(obj.tankSize);
      for i=1:length(fishIndividuals)
        tank(fishIndividuals(i).position(1),fishIndividuals(i).position(2)) = i; 
      end

      bigTank = [tank' tank' tank';tank' tank' tank';tank' tank' tank'];
      bigTank = bigTank > 1;

      fishInObs = obj.fishInObserveDist(obj.observeDist);
      fishInFront = obj.fishInAngle(pi/2);
      fishInBack = ~fishInFront;
      fishInScope = {fishInFront, fishInBack};
    
      for i=1:length(fishInScope)
        fish = bigTank;
        fish(~and(fishInObs,fishInScope{i})) = 0; % Rm all not in scope or dist
        center = obj.massCenter(fish);            % Get relative center of shoal  
        if sum(isnan(center)) > 0 || isequal(center,[0,0])
          angle = 0.5;
          dist = 0;
        else
          dist = 1 - norm(center)/obj.observeDist;
          angle = obj.normAngle(center);
        end
        brainInputs(i) = dist;
        brainInputs(3 + i) = angle;
      end 

      close_fish = bigTank;
      close_fish( ...
        ~and(obj.fishInObserveDist(obj.maxSpeed), ...
             obj.fishInAngle(obj.moveAngle)) ) = 0;
      [close_dists, close_angles] = obj.fishClose(close_fish);  
      brainInputs(3) = close_dists;
      brainInputs(6) = close_angles;

      [normSpeed, normDir] = obj.brain.getMovement(brainInputs'); 
      [newPos, newDir] = obj.newPosition(normSpeed,normDir,obj.moveAngle);

      obj.position = newPos;
      obj.direction = newDir;

      if tank(obj.position(1), obj.position(2)) > 1
        iFish = tank(obj.position(1), obj.position(2));
        fishIndividuals(iFish) = []; 
        obj.fishEaten = obj.fishEaten + 1;
      end 
      obj.energy = obj.energy + ( floor(velocity*obj.maxSpeed)+1 ); 
      if obj.fishEaten >= obj.fishEatGoal || obj.energy >= obj.maxEnergy
        if obj.energy >= obj.maxEnergy
          obj.energy = obj.maxEnergy;
        end
        obj.hunting = false;
      end
    end

    function [pos, direction] = newPosition(obj, velocity, direction, angle)
      phi = (obj.direction(1) < 0)*pi;
      steps = floor(velocity*obj.maxSpeed)+1;
      sharkAngle = atan(obj.direction(2)/obj.direction(1))+phi;
      moveAngle = sharkAngle-angle+2*direction*angle;
      % Position relative shark
      direction = [steps*cos(moveAngle),steps*sin(moveAngle)];
      pp = round([steps*cos(moveAngle),steps*sin(moveAngle)]);
      % Position in tank
      P = pp + obj.position;
      for i=1:2
        if P(i) > obj.tankSize
          p(i) = P(i) - obj.tankSize;
        elseif P(i) <= 0 
          p(i) = P(i) + obj.tankSize; 
        else
          p(i) = P(i);
        end
      end
      pos = p;
    end

    function [dists, angles] = fishClose(obj,fish)
      angle = obj.moveAngle;
      nr = obj.closeObserve; 
      if sum(sum(fish)) == 0
        dists = zeros(1,nr);
        angles = 0.5*ones(1,nr);
        return
      end
      gs = 3*obj.tankSize; 
      iX = (1:gs)'*ones(1,gs);
      iY = ones(gs,1)*(1:gs);
      xs = iX(fish)-(obj.position(1)+obj.tankSize); 
      ys = iY(fish)-(obj.position(2)+obj.tankSize);

      dists = arrayfun( @(x,y) 1-norm([x,y])/obj.maxSpeed, xs,ys);
      [dists, iSort] = sort(dists,'descend');
      dists = dists(1:nr);
      sharkBase = [cos(angle),-sin(angle);sin(angle),cos(angle)]*obj.direction';
      angles = arrayfun( @(x,y) ...
        2*acos(dot([x,y],sharkBase')/(norm([x,y])*norm(sharkBase)))/pi,xs,ys);
      angles = angles(iSort);
      angles = angles(1:nr); 
    end

    function angle = normAngle(obj,center)
        % Get angle from line that separates front and back
        sharkBase = [0,1;-1,0]*obj.direction';
        angle = acos(dot(center,sharkBase')/(norm(center)*norm(sharkBase)))/pi;
    end
   
    % Return position relative to shark
    function pos = massCenter(obj,shoal)
      gs = obj.tankSize * 3;
      sx = obj.position(1) + obj.tankSize;
      sy = obj.position(2) + obj.tankSize;
      x = dot(sum(shoal,2)',(1:gs)) / sum(sum(shoal)) - sx;
      y = dot(sum(shoal,1),(1:gs)) / sum(sum(shoal)) - sy;
      pos = [x,y];
    end

    function iFish = fishInAngle(obj,angle)
      s = obj.position + obj.tankSize;
      d = obj.direction;
      gs = 3*obj.tankSize; 
      iX = (1:gs)'*ones(1,gs)-s(1);
      iY = ones(gs,1)*(1:gs)-s(2);
        
      iFish = arrayfun( @(x,y) ...
        sign(angle)*acos(dot([x,y],d')/(norm([x,y])*norm(d))) <= angle,iX,iY);
    end

    function iFish = fishInObserveDist(obj, dist)
      gs = 3*obj.tankSize; 
      iX = (1:gs)'*ones(1,gs);
      iY = ones(gs,1)*(1:gs);
      X = obj.position(1) + obj.tankSize;
      Y = obj.position(2) + obj.tankSize; 
      iFish = arrayfun( @(x,y) ...
        sqrt((X-x)^2 + (Y-y)^2) <= dist,iX, iY);
    end

  end
end
