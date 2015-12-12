classdef DrawFish
 
properties
 movieFrames
 aq
 figIndex
end
 
methods
 % Use an object of class Aquarium as input.
 function obj = DrawFish(aquarium) % Constructor.
  obj.movieFrames = [];
  obj.aq = aquarium;
  obj.figIndex = 1;
 end
 
 function stillfig(obj) % Draw figure of current Aquarium.
  % Usage: thisObject.stillfig in loop with Aquarium.
  figure(1)
  N = length(obj.aq.fishShoal.fishes);
  coordinates = zeros(N,2);
  for i = 1:N
   coordinates(i,:) = obj.aq.fishShoal.fishes(i).position;
  end
  plot(obj.aq.shark.position(1),obj.aq.shark.position(2),'r.','markersize',20)
  hold on
  plot(coordinates(1:end,1),coordinates(1:end,2),'.','markersize',10)
  axis([0 obj.aq.tankSize 0 obj.aq.tankSize])
  hold off
  drawnow
 end
 
 function obj = exportFigure(obj) % Export current Aquarium.
  % Usage: thisObject = thisObject.exportFigure after stillfig.
  exportPath = sprintf('../data/figure%i.png',obj.figIndex);
  obj.figIndex = obj.figIndex + 1;
  print(exportPath,'-dpng')
 end
 
 function obj = animate(obj) % Record movie.
  % Usage: thisObject = thisObject.animate in loop with Aquarium.
  movieHandle = figure(1);
  N = length(obj.aq.fishShoal.fishes);
  coordinates = zeros(N,2);
  for i = 1:N
   coordinates(i,:) = obj.aq.fishShoal.fishes(i).position;
  end
  plot(obj.aq.shark.position(1),obj.aq.shark.position(2),'r.','markersize',20)
  hold on
  plot(coordinates(1:end,1),coordinates(1:end,2),'.','markersize',10)
  axis([0 obj.aq.tankSize 0 obj.aq.tankSize])
  hold off
  drawnow
  obj.movieFrames = [obj.movieFrames getframe(movieHandle)];
 end
 
 function exportMovie(obj) % Export recorded movie.
  % Usage: thisObject.exportMovie after evaluation loop.
  exportPath = sprintf('../data/movie.avi');
  v = VideoWriter(exportPath);
  open(v)
  writeVideo(v,obj.movieFrames)
  close(v)
 end
end
end