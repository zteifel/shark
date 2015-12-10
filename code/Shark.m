classdef Shark % < Animal
  properties
    position = [2,2];
    direction = [1,0];
    observeDist = 4;
    tankSize = 5;
    % brain = WalnutBrain();
    maxSpeed = 5;
    stamina = 25;
    moveAngle = pi/2;
    closeObserve = 1;
    hunting = true;
  end

  methods
    function obj = Shark(position,obsdist,tanksize,weights,beta);
        obj.position = position;
        obj.observeDist = obsdist;
        dir = [0,0];
        while sum(dir) > 0
            dir = randi(3,1,2)-2;
        end 
        obj.direction = dir; 
        obj.tankSize = tanksize;
        if weights == 0
            obj.brain = WalnutBrain(0.5,0.5);
        else
            obj.brain = AIBrain(weights,beta);
        end 
    end


    function position = updatePosition(obj, tank)
      bigTank = [tank' tank' tank';tank' tank' tank';tank' tank' tank'];

      fishVisible = fishInObserveDist(obj.observeDist);
      fishInFront = fishInAngle(pi/2);

      front.fish = bigTank > 0;
      front.fish(~and(fishVisible,fishInFront)) = 0;
      front.center = getMassCenter(front.fish);
      front.dist = 1 - norm(front.center)/obj.observeDist;
      front.angle = getNormAngle(front.center);
 
      back.fish = bigTank > 0 ;
      back.fish(~and(fishVisible,~fishInFront)) = 0;
      back.center = getMassCenter(back.fish);
      back.dist =  1 - norm(back.center)/obj.observeDist;
      back.angle = getNormAngle(back.center);

      close.fish = bigTank > 0;
      close.fish( ...
        and(fishInObserveDist(obj.maxspeed),getFishInAngle(obj.moveAnlge)));
      [close.dists, close.angles] = ...
        getFishClose(close.fish,obj.moveAnlge,obj.closeObserve);  

      brainInput = [front.dist back.dist close.dists ...
                    front.angle back.angle close.angles];

      [velocity, direction] = obj.brain.getMovement(brainInputs); 
      obj.position = getNewPosition(velocity,direction,obj.moveAnlge);
       
      obj.stamina = obj.stamina - velocity;
      if stamina <=0
        obj.hunting = false;
      end
    end

    function p = getNewPosition(obj, velocity, direction, angle)
      steps = floor(velocity*obj.maxspeed)+1;
      sharkAngle = (x>=2)*(atan(obj.direction(2)/obj.direction(1))) + ...
                   (x<0)*(atan(obj.direction(2)/obj.direction(1))+pi);
      moveAngle = sharkAngle-angle+2*direction*angle;
      % Position relative shark
      pp = [steps*cos(moveAngle),steps*sin(moveAngle)];
      % Position in bigTank
      P = pp + obj.position;
      % Position in tank
      for i=1:2
        if P(i) > 2*obj.tankSize
          p(i) = P(i) - 2*obj.tankSize;
        elseif P(i) > obj.tankSize
          p(i) = P(i) - obj.tankSize; 
        else
          p(i) = P(i);
        end
      end
    end

    function [dists, angles] = getFishClose(obj,fish,angle,nr)
      gs = 3*obj.tankSize; 
      iX = ones(gs,1)*(1:gs);
      iY = (1:gs)'*ones(1,gs);
      xs = iX(fish)-obj.position(1);
      ys = iY(fish)-obj.position(2);
      
      dists = arrayfun( @(x,y) norm([x,y]));
      [dists, iSort] = sort(dists);
      dists = dists(1:nr);
      sharkBase = [cos(angle),-sin(angle);sin(angle),cos(angle)]*obj.direction';
      angles = arrayfun( @(x,y) ...
        acos(dot([x,y],sharkBase')/(norm([x,y])*norm(sharkBase)))/pi;
      angles = angles(iSort);
      angles = angles(1:nr); 
    end

    function iFish = fishInAngle(obj,angle)
      s = obj.position+obj.tankSize;
      sd = obj.direction;
      gs = 3*obj.tankSize;
      iX = ones(gs,1)*(1:gs)-s(1);
      iY = (1:gs)'*ones(1,gs)-s(2);
      iFish = arrayfun( @(i,j) ...
        sign(angle)*acos(dot([i,j],sd')/(norm([i,j])*norm(sd))) <= angle,iX,iY);
    end
   
    function angle = getNormAngle(obj,center)
        % Get angle from line that separates front and back
        sharkBase = [0,1;-1,0]*obj.direction';
        angle = acos(dot(center,sharkBase')/(norm(center)*norm(sharkBase)))/pi;
    end


    % Return position relative to shark
    function [x,y] = getMassCenter(obj,shoal)
      gs = obj.tankSize*3;
      x = sum(sum(shoal).*(1:gs)) / (sum(sum(shoal)) - obj.position(1) );
      y = sum(sum(shoal,22).*(1:gs)') / (sum(sum(shoal)) - obj.position(2) );
    end

    function iFish = fishInObserveDist(obj, dist)
      gs = 3*obj.tankSize; 
      iX = ones(gs,1)*(1:gs);
      iY = (1:gs)'*ones(1,gs);
      X = obj.position(1)+obj.tankSize;
      Y = obj.position(2)+obj.tankSize; 
      iFish = arrayfun( @(x,y) ...
        sqrt((X-x)^2 + (Y-y)^2) <= dist,iX, iY);
    end

  end
end
