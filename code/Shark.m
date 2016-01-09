classdef Shark < Animal
  properties
    position
    direction
    observeDist
    distToFish = 0;
    brain
    maxSpeed
    energy = 0;
    maxEnergy
    moveAngle
    closeObserve
    hunting = true;
    fishEaten = 0;
    drawInputs
  end

  methods
    function obj = Shark(consts,weights,beta);
        if not(isreal(consts.position))
          disp('NOT REAL IN INIT')
        end
        obj.position = consts.position;
        obj.observeDist = consts.observeDist;
        obj.maxSpeed = consts.maxSpeed;
        obj.maxEnergy = consts.maxEnergy;
        obj.moveAngle = consts.moveAngle*pi;
        obj.closeObserve = consts.closeObserve;
        dir = [0,0];
        while sum(abs(dir)) < 1
            dir = randi(3,1,2)-2;
        end
        obj.direction = dir;
        if length(weights) == 0 || isempty(weights)
            obj.brain = AIBrain(obj.moveAngle);
        else
            obj.brain = ANNBrain(weights,beta);
        end
    end

    function fish = updatePosition(obj, fish)

      if not(isreal(obj.position))
        disp('position not real')
        obj.position
      end

      % Get Positions from all fish
      pos = [arrayfun(@(x) x.position(1),fish); ...
             arrayfun(@(x) x.position(2),fish)];

      % Transform in to shark coordinates
      allPos = [pos(1,:)-obj.position(1);pos(2,:)-obj.position(2)];

      % Compute distancs to shark
      dists = arrayfun(@(x,y) norm([x,y]),allPos(1,:),allPos(2,:));

      % sort based on dist to shark
      [dists, iSort] = sort(dists);
      allPos = allPos(:,iSort);

      % remove those further away then observe distans
      iDists = dists <= obj.observeDist;

      if sum(iDists) == 0 % Shark has lost contact with fish => break
        brainInputs = [0,0,0,0.5,0.5,0.5];
        drawInputs.fc = [0,0];
        drawInputs.bc = [0,0];
        drawInputs.cc = [0,0];
        drawInputs.pos = obj.position;
        drawInputs.dir = obj.direction;
        obj.hunting = false;
        obj.drawInputs = drawInputs;
        obj.energy = obj.maxEnergy;
        disp('shark lost contact')
        return
      else
        dists = dists(iDists);
        allPos = allPos(:,iDists);
        angles = obj.getAngles(allPos);

        % Fish in front
        iFront = 3*pi/2<angles | angles<pi/2;
        if sum(iFront) == 0 || isempty(iFront)
          fc = [0,0]; fd = 0; fa = 0.5;
        else
          fc = sum(allPos(:,iFront),2)/size(allPos(:,iFront),2);
          [fd,fa] = obj.getNormPolPos(pi/2,fc,obj.observeDist);
        end
        %Fish in back
        iBack = ~iFront;
        if sum(iBack) == 0 || isempty(iBack)
          bc = [0,0]; bd = 0; ba = 0.5;
        else
          bc = sum(allPos(:,iBack),2)/size(allPos(:,iBack),2);
          [bd,ba] = obj.getNormPolPos(-pi/2,bc,obj.observeDist);
        end
        % Fish close
        cc = ...
          allPos(:,find(abs(angles) < obj.moveAngle,1));
        if isempty(cc) || norm(cc) > obj.maxSpeed
          cc = [0,0]; cd = 0; ca = 0.5;
        else
          [cd,ca] = obj.getNormPolPos(obj.moveAngle,cc,obj.maxSpeed);
        end
        % Create drawInputs
        drawInputs.fc = fc; drawInputs.bc = bc;
        drawInputs.cc = cc; drawInputs.pos = obj.position;
        % Create brain inputs
        brainInputs = [fd,bd,cd,fa,ba,ca];
      end
      obj.drawInputs = drawInputs;
      obj.drawInputs.dir = obj.direction;

      [normSpeed, normDir] = obj.brain.getMovement(brainInputs');

      [newPos, newDir] = obj.newPosition(normSpeed,normDir,obj.moveAngle);
      if not(isreal(newPos))
        brainInputs
        disp('pos is not real!')
      end
      obj.position = newPos;
      obj.direction = newDir;

      % Compute dist to fish in this iteration
      if brainInputs(2) > brainInputs(1)
        obj.distToFish = obj.distToFish + brainInputs(2);
      else
        obj.distToFish = obj.distToFish + brainInputs(1);
      end

      % Check if shark caught fish, if so, then kill it.
      iFishEat = find(pos(1,:) == obj.position(1) & pos(2,:) == obj.position(2),1);
      fish(iFishEat) = [];
      if not(isempty(iFishEat))
        obj.fishEaten = obj.fishEaten + 1;
      end

      obj.energy = obj.energy + ( floor(normSpeed*obj.maxSpeed)+1 );
      if obj.energy >= obj.maxEnergy
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
      pos = pp + obj.position;
    end

    function [dist, angle] = getNormPolPos(obj,normAngle,pos,normDist);
      dist = 1-norm(pos)/normDist;
      d = obj.direction;
      aShark = mod(atan2(d(2),d(1))+2*pi-normAngle,2*pi);
      aFish = mod(atan2(pos(2),pos(1))+2*pi,2*pi);
      if round(aShark,5) > round(aFish,5)
        aShark = -(2*pi-aShark);
      end
      angle = (aFish-aShark)/(2*abs(normAngle));
    end

    function angles = getAngles(obj, fishPos)
        d = obj.direction;
        angles = arrayfun(@(x,y) ...
          mod(atan2(y,x)-atan2(d(2),d(1))+2*pi,2*pi),fishPos(1,:),fishPos(2,:));
    end

  end
end

