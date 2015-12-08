classdef Shark % < Animal
  properties
    position = [2,2];
    direction = [1,0];
    observeDist = 2;
    tankSize = 5;
    brain = WalnutBrain();
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
            obj.brain = WalnutBrain();
        else
            obj.brain = AIBrain(weights,beta);
        end 
    end


    function position = updatePosition(obj, tank)
      bigTank = [tank' tank' tank';tank' tank' tank';tank' tank' tank'];

      fishVisible = getFishPosInObserveDist();
      fishInFront = getFishPosInFront();

      front.fish = tank > 0;
      front.fish(~and(fishVisible,fishInFront)) = 0;
      front.center = getMassCenter(front.fish);
      front.dist = norm(front.center);
      front.angle = getNormAngle(front.center);
 
      back.fish = tank > 0 ;
      back.fish(~and(fishVisible,~fishInFront)) = 0;
      back.center = getMassCenter(back.fish);
      back.dist = norm(back.center);
      back.angle = getNormAngle(back.center);
      
      brainInput = [front.dist, front.angle, back.dist, back.angle];

      [steps, direction] = obj.brain.getMovement(brainInputs); 

    end
    

    function angle = getNormAngle(obj,center)
        % Get angle from line that separates front and back
        sharkBase = [0,1;-1,0]*obj.direction';
        angle = acos(dot(center,sharkBase')/(pi*norm(center)*norm(sharkBase));
    end

    % Return position relative to shark
    function [x,y] = getMassCenter(obj,shoal)
      gs = obj.tankSize*3;
      x = sum(sum(shoal).*(1:gs)) / (sum(sum(shoal)) - obj.position(1);
      y = sum(sum(shoal,22).*(1:gs)') / (sum(sum(shoal)) - obj.position(2);
    end

    function iFish = getFishPosInObserveDist(obj)
      gs = 3*obj.tankSize; 
      iX = ones(gs,1)*(1:gs);
      iY = (1:gs)'*ones(1,gs);
      X = obj.position(1)+obj.tankSize;
      Y = obj.position(2)+obj.tankSize; 
      iFish = arrayfun( @(x,y) ...
        sqrt((X-x)^2 + (Y-y)^2) <= obj.observeDist,iX, iY);
    end

    function iFishFront = getFishPosInFront(obj)
      gs = 3*obj.tankSize; 
      iX = ones(gs,1)*(1:gs);
      iY = (1:gs)'*ones(1,gs);
      X = obj.position(1)+obj.tankSize;
      Y = obj.position(2)+obj.tankSize; 
      k = -obj.direction(1)*obj.direction(2)
      m = Y-k*X;

      iFishFront = arrayfun(@(x,y) ...
        (k~=0) && ( ...
          obj.direction(2)>0 && ( y>=k*x+m ) || ...
          obj.direction(2)<0 && ( y<=k*x+m )    ...
        ) || ...
        (k==0) && ( ...
          (obj.direction(1)>0) && ( x>=X ) || ...
          (obj.direction(1)<0) && ( x<=X ) || ...
          (obj.direction(1)>0) && ( y>=Y ) || ...
          (obj.direction(1)<0) && ( y<=Y )    ...
        ), iX,iY); 
    end

  end
end
