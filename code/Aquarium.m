classdef Aquarium < handle

  properties
    shark
    tankSize
    fishShoal
    fig
    visTraining
  end

  methods
    function obj = Aquarium(...
            shark_consts, tank_consts, fish_consts, weights, beta, visTraining)
      obj.tankSize = tank_consts.tankSize;
      % Create fish shoal
      obj.fishShoal = FishShoal(tank_consts.tankSize, tank_consts.nrOfFish,...
        fish_consts.driftSpeed, fish_consts.maxSpeed, fish_consts.scareDistance,...
        fish_consts.attractionDistance, fish_consts.accelerationRate);
      % Create shark
      dist = ...
        randi(round(0.5*shark_consts.observeDist))+0.25*shark_consts.observeDist;
      c = obj.fishShoal.averagePosition;
      dx = (1-2*(randi(2)-1))*(randi(floor(dist)+1)-1);
      dy = (1-2*(randi(2)-1))*round(sqrt(dist^2-dx^2));
      x = round(c(1)+dx);
      y = round(c(2)+dy);
      shark_consts.position = [x y];
      obj.shark = Shark(shark_consts, weights, beta);
      obj.visTraining = visTraining;
      if visTraining
        obj.fig = obj.initFig();
      end
    end

    function fitness = run(obj)
      count = 0;
      while obj.shark.hunting
          count = count + 1;
          obj.fishShoal.updateFishes(obj.shark.position);
          obj.fishShoal.fishes = obj.shark.updatePosition(obj.fishShoal.fishes);
          if obj.visTraining
            obj.updateFig();
          end
      end
      distToFish = (obj.shark.distToFish/count)^2;
      fitness = (obj.shark.fishEaten+distToFish);
    end

    function fig = initFig(obj)
      fig = figure(2);
      fishpos = [arrayfun(@(x) x.position(1),obj.fishShoal.fishes); ...
                 arrayfun(@(x) x.position(2),obj.fishShoal.fishes)];
      fishX = obj.fishShoal.fishes(1).position(1);
      fishY = obj.fishShoal.fishes(1).position(2);

      sc = plot(fishpos(1,:),fishpos(2,:),'.'); hold on;

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
      axis([obj.fishShoal.averagePosition(1)-obj.tankSize/2 ...
            obj.fishShoal.averagePosition(1)+obj.tankSize/2 ...
            obj.fishShoal.averagePosition(2)-obj.tankSize/2 ...
            obj.fishShoal.averagePosition(2)+obj.tankSize/2]);
    end

    function updateFig(obj)
      fishpos = [arrayfun(@(x) x.position(1),obj.fishShoal.fishes); ...
                 arrayfun(@(x) x.position(2),obj.fishShoal.fishes)];
      inputs = obj.shark.drawInputs;
      h = guidata(obj.fig);

      if not(isreal(inputs.pos))
        inputs
      end

      set(h.sc,'XData',fishpos(1,:), ...
               'YData',fishpos(2,:));
      set(h.qd,'XData',inputs.pos(1), 'YData', inputs.pos(2), ...
               'UData',inputs.dir(1), 'VData', inputs.dir(2));
      set(h.qf,'XData',inputs.pos(1), 'YData', inputs.pos(2), ...
               'UData',inputs.fc(1), 'VData', inputs.fc(2));
      set(h.qb,'XData',inputs.pos(1), 'YData', inputs.pos(2), ...
               'UData',inputs.bc(1), 'VData', inputs.bc(2));
      set(h.qc,'XData',inputs.pos(1), 'YData', inputs.pos(2), ...
               'UData',inputs.cc(1), 'VData', inputs.cc(2));
      set(obj.fig.Children, ...
            'XLim', [...
            obj.fishShoal.averagePosition(1)-obj.tankSize/2 ...
            obj.fishShoal.averagePosition(1)+obj.tankSize/2], ...
            'YLim', [...
            obj.fishShoal.averagePosition(2)-obj.tankSize/2 ...
            obj.fishShoal.averagePosition(2)+obj.tankSize/2]);
      drawnow;
    end

  end

end
