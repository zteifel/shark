% VERY WIP!
classdef DrawFish % < Aquarium
 
methods
 function obj = DrawFish(tankSize,positions,inhabitants)
  if(nargin == 0)
   tankSize = 100;
   positions = randi(tankSize,51,2);
   inhabitants = 1:size(positions,2);
  end
%  obj@Aquarium(tankSize,positions,inhabitants);
  obj.tankSize = tankSize;
  obj.positions = positions;
  obj.inhabitants = inhabitants;
 end
 
 function drawMap()
  obj.graphicHandle = figure;
  hold on
  plot(obj.positions(1,1),obj.positions(2,1),'*b') % Plot shark.
  for i=2:size(obj.positions,1)
   if(obj.inhabitants(i)~=0)
    plot(obj.positions(1,i),obj.positions(2,i),'.r') % Plot living fish.
   end
  end
  axis([0 obj.tankSize 0 obj.tankSize])
  hold off
 end
end
 
end