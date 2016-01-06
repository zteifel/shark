classdef Aquarium < handle
    
    properties
        shark
        tankSize
        fishShoal
    end
    
    methods
        function obj = Aquarium(shark_consts, tank_consts, fish_consts, weights, beta)
            obj.tankSize = tank_consts.tankSize;
            % Create shark
            shark_consts.position = ...
                randi(round(0.1*obj.tankSize),1,2) + round(0.1*obj.tankSize);
            shark_consts.tankSize = tank_consts.tankSize;
            obj.shark = Shark(shark_consts, weights, beta);
            % Create fish shoal
            obj.fishShoal = FishShoal(tank_consts.tankSize, tank_consts.nrOfFish,...
                fish_consts.driftSpeed, fish_consts.maxSpeed, fish_consts.scareDistance,...
                fish_consts.attractionDistance);
        end
        
        function fitness = run(obj)
            count = 0;
            while obj.shark.hunting
                count = count + 1;
                obj.fishShoal.updateFishes(obj.shark.position);
                obj.fishShoal.fishes = obj.shark.updatePosition(obj.fishShoal.fishes);
                
%                 N = length(obj.fishShoal.fishes);
%                 p.x = zeros(1,N);
%                 p.y = zeros(1,N);
%                 for i = 1:N
%                     p.x(i) = obj.fishShoal.fishes(i).position(1);
%                     p.y(i) = obj.fishShoal.fishes(i).position(2);
%                 end
%                 plot(p.x,p.y,'.','markersize',10);
%                 hold on
%                 plot(obj.shark.position(1),obj.shark.position(2),'r.','markersize',12)
%                 axis([-100 350 -100 350])
%                 hold off
%                 drawnow
            end
            distToFish = (obj.shark.distToFish/count)^2;
            fitness = (obj.shark.fishEaten+distToFish)/obj.shark.energy;
        end
    end
    
end
