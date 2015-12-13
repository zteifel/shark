classdef VisualizeTank
  properties
    fig
    limits
  end

  methods
    function obj = VisualizeTank(tankSize)
      obj.fig = figure();
      obj.limits = [-1 tankSize+1  -1 tankSize+1];
      axis(obj.limits)
      axis manual
    end

    function drawShark(obj,shark)
      figure(obj.fig);
      points = [shark.prevPosition(1) shark.prevDirection(1) ...
                shark.prevPosition(2) shark.prevDirection(2) ];
      color = 'k';
      obj.drawarrow(points,color);
      for i=1:length(shark.drawInput)/2
        xstart = shark.prevPosition(1);
        ystart = shark.prevPosition(2);
        xfinal = shark.drawInput(2*(i-1)+1);
        yfinal = shark.drawInput(2*(i-1)+2);
        points = [xstart xfinal ystart yfinal];
        if isnan(points) == 0
          obj.drawarrow(points,'k');
        end
      end
      axis(obj.limits);
      axis manual
      drawnow; 
    end

    function drawFish(obj, animals)
      figure(obj.fig); hold off;
      for i=1: length(animals)
        a = animals{i};
        if a.alive
          points = [ a.position(1) a.velocity(1) ...
                     a.position(2) a.velocity(2) ];
          color = 'r';
          obj.drawarrow(points,color);
        end
      end 
      axis(obj.limits);
      axis manual
      drawnow;
       
    end 

    function drawarrow(obj,points,color)
      figure(obj.fig);
      quiver(...
        points(1),points(3),points(2),points(4),0,'Color',color); hold on;
      scatter(points(1),points(3),'filled'); hold on;
    end
  end

end
