classdef Aquarium < handle
    
  properties
    shark
    positions
    tankSize
    %fig
  end

  methods
    function obj = Aquarium(shark_consts, tank_consts, fish_consts, weights, beta);
      obj.tankSize = tank_consts.tankSize;
      % Create shark
      shark_consts.position = randi(obj.tankSize,1,2); 
      shark_consts.tankSize = tank_consts.tankSize;
      obj.shark = Shark(shark_consts, weights, beta);
      % Create fish
      fishPos = obj.posNotCloseToShark(obj.shark.position);
      positions = zeros(obj.tankSize);
      positions(fishPos(1),fishPos(2)) = 2;
      obj.positions = positions; 

      %obj.fig = obj.initFig();


    end

    function fig = initFig(obj)
        fig = figure(2);
        [fishX,fishY] = find(obj.positions == 2);
        sc = scatter([fishX obj.shark.position(1)], ...
                     [fishY obj.shark.position(2)], ...
                     'filled'); hold on;
        qf = quiver(obj.shark.position(1),obj.shark.position(2),0,0,0, 'r');
        hold on;
        qb = quiver(obj.shark.position(1),obj.shark.position(2),0,0,0, 'g');
        hold on;
        qc = quiver(obj.shark.position(1),obj.shark.position(2),0,0,0,'k');
        hold off;
        h = guidata(fig);
        h.sc = sc; h.qf = qf; h.qb = qb; h.qc = qc;
        guidata(fig,h); 
        axis equal;
        axis([0 obj.tankSize 0 obj.tankSize]);
    end

    function newPos = posNotCloseToShark(obj,pos)
      dist = randi(obj.tankSize/2,1,2)+obj.tankSize/4;
      newPos = pos + (1-2*(randi(2,1,2)-1)).*dist;
      for i=1:2
        if newPos(i) > obj.tankSize
            newPos(i) = newPos(i)-obj.tankSize;
        elseif newPos(i) < 1
            newPos(i) = newPos(i) + obj.tankSize;
        end
      end
    end

    function updateFig(obj)
      [fishX,fishY] = find(obj.positions==2);
      inputs = obj.shark.drawInputs;
      h = guidata(obj.fig);
      set(h.sc,'XData',[fishX inputs.pos(1)], ...
               'YData',[fishY inputs.pos(2)]);
      set(h.qf,'XData',inputs.pos(1), 'YData', inputs.pos(2), ...
               'UData',inputs.fc(1), 'VData', inputs.fc(2));
      set(h.qb,'XData',inputs.pos(1), 'YData', inputs.pos(2), ...
               'UData',inputs.bc(1), 'VData', inputs.bc(2));
      set(h.qc,'XData',inputs.pos(1), 'YData', inputs.pos(2), ...
               'UData',inputs.cc(1), 'VData', inputs.cc(2));
      drawnow;
    end

    function fitness = run(obj)
      while obj.shark.hunting 
        % Update shark position
        newPos = obj.shark.updatePosition(obj.positions);
        %obj.updateFig();

        if obj.positions(newPos(1),newPos(2)) > 1
            obj.positions(newPos(1),newPos(2)) = 0;
        end
        %if obj.positions(newPos(1),newPos(2)) > 1
        if rand < 0.05
            obj.positions = zeros(obj.tankSize);

            fishPos = obj.posNotCloseToShark(newPos);
            obj.positions(fishPos(1),fishPos(2)) = 2;
        end
      end
      avgDist = mean(obj.shark.distToFish);
      fitness = (avgDist^2); 
    end 
  end

end
