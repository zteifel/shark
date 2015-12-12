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
                randi(round(0.25*obj.tankSize),1,2) + round(0.5*obj.tankSize);
            shark_consts.tankSize = tank_consts.tankSize;
            obj.shark = Shark(shark_consts, weights, beta);
            % Create fish shoal
            obj.fishShoal = FishShoal(tank_consts.tankSize, tank_consts.nrOfFish, fish_consts.maxSpeed);
        end
        
        function fitness = run(obj,draw)
            while obj.shark.hunting
                
                obj.shark.updatePosition(obj.fishShoal.fishes);
                
                for i=1:length(obj.inhabitants)
                    newPos = obj.inhabitants{i}.updatePosition(obj.positions);
                    if i==1 && obj.positions(newPos(1), newPos(2)) > 1; % Kill fish
                        caughtFish = obj.positions(newPos(1),newPos(2));
                        obj.inhabitants{caughtFish}.alive = false;
                        obj.positions(newPos(1),newPos(2)) = 0;
                    end
                    pos(newPos(1),newPos(2)) = i;
                end
                obj.positions = pos;
                
                
                % Temporary way to visualize the model.
                if (draw)
                    figure(1)
                    N = length(obj.inhabitants);
                    coordinates = zeros(N,2);
                    for i = 1:N
                        coordinates(i,:) = obj.inhabitants{i}.position;
                    end
                    plot(coordinates(1,1),coordinates(1,2),'r.','markersize',20)
                    hold on
                    plot(coordinates(2:end,1),coordinates(2:end,2),'.','markersize',10)
                    axis([0 obj.tankSize 0 obj.tankSize])
                    hold off
                    drawnow
                end
            end
            fitness = (obj.inhabitants{1}.fishEaten/obj.inhabitants{1}.energy);
            
            
        end
    end
    
end
