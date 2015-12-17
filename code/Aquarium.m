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
                randi(round(0.25*obj.tankSize),1,2) + round(0.1*obj.tankSize);
            shark_consts.tankSize = tank_consts.tankSize;
            obj.shark = Shark(shark_consts, weights, beta);
            % Create fish shoal
            obj.fishShoal = FishShoal(tank_consts.tankSize, tank_consts.nrOfFish,...
                fish_consts.driftSpeed, fish_consts.maxSpeed, fish_consts.scareDistance);
        end
        
        function fitness = run(obj,draw)
            while obj.shark.hunting
                
                obj.fishShoal.updateFishes(obj.shark.position);
                
                obj.fishShoal.fishes = obj.shark.updatePosition(obj.fishShoal.fishes);
                
                
                % Temporary way to visualize the model.
                if (draw)
                    figure(1)
                    N = length(obj.fishShoal.fishes);
                    coordinates = zeros(N,2);
                    for i = 1:N
                        coordinates(i,:) = obj.fishShoal.fishes(i).position;
                    end
                    plot(obj.shark.position(1),obj.shark.position(2),'r.','markersize',20)
                    hold on
                    plot(coordinates(1:end,1),coordinates(1:end,2),'.','markersize',10)
                    axis([0 obj.tankSize 0 obj.tankSize])
                    hold off
                    drawnow
                end
            end
            fitness = (obj.shark.fishEaten/obj.shark.energy);
            
            
        end
    end
    
end
