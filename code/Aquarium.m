classdef Aquarium < handle

  properties
    shark
    fishShoal
    tankSize
    %fig
  end

  methods
    function obj = Aquarium(shark_consts, tank_consts, fish_consts, weights, beta);
      obj.tankSize = tank_consts.tankSize;

      % Create shark
      shark_consts.position = randi(obj.tankSize,1,2),
      shark_consts.tankSize = tank_consts.tankSize;
      obj.shark = Shark(shark_consts, weights, beta);

      % Create fish
      fishPos = obj.posNotCloseToShark(obj.shark.position);
      obj.fishShoal = struct('fishes', ...
        [struct('position',fishPos),struct('position',fishPos)]);

      obj.fig = obj.initFig();
    end

    function fig = initFig(obj)
        fig = figure(2);
        fishX = obj.fishShoal.fishes(1).position(1);
        fishY = obj.fishShoal.fishes(1).position(2);

        sc = scatter([fishX obj.shark.position(1)], ...
                     [fishY obj.shark.position(2)], ...
                     'filled'); hold on;

        qd = quiver(obj.shark.position(1),obj.shark.position(2),0,0,0, 'b');
        hold on;
        qf = quiver(obj.shark.position(1),obj.shark.position(2),0,0,0, 'r');
        hold on;
        qb = quiver(obj.shark.position(1),obj.shark.position(2),0,0,0, 'g');
        hold on;
        qc = quiver(obj.shark.position(1),obj.shark.position(2),0,0,0,'k');
        hold off;

        h = guidata(fig);
        h.sc = sc; h.qd = qd; h.qf = qf; h.qb = qb; h.qc = qc;
        guidata(fig,h);
        axis equal;
        axis([0 obj.tankSize 0 obj.tankSize]);
    end

    function updateFig(obj)
      fishX = obj.fishShoal.fishes(1).position(1);
      fishY = obj.fishShoal.fishes(1).position(2);
      inputs = obj.shark.drawInputs;
      h = guidata(obj.fig);
      set(h.sc,'XData',[fishX inputs.pos(1)], ...
               'YData',[fishY inputs.pos(2)]);
      set(h.qd,'XData',inputs.pos(1), 'YData', inputs.pos(2), ...
               'UData',inputs.dir(1), 'VData', inputs.dir(2));
      set(h.qf,'XData',inputs.pos(1), 'YData', inputs.pos(2), ...
               'UData',inputs.fc(1), 'VData', inputs.fc(2));
      set(h.qb,'XData',inputs.pos(1), 'YData', inputs.pos(2), ...
               'UData',inputs.bc(1), 'VData', inputs.bc(2));
      set(h.qc,'XData',inputs.pos(1), 'YData', inputs.pos(2), ...
               'UData',inputs.cc(1), 'VData', inputs.cc(2));
      drawnow;
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

    function fitness = run(obj)
      count = 0;
      while obj.shark.hunting
        count = count + 1;
        % Update shark position
        newPos = obj.shark.updatePosition(obj.fishShoal.fishes);
        obj.updateFig();
      end
      avgDist = obj.shark.distToFish/count;
      fitness = (avgDist^2);
    end
  end

end
