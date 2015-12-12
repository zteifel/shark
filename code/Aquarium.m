classdef Aquarium < handle
    
    properties
        inhabitants
        positions
        tankSize
        fishcalculation
    end
    
    methods
        function obj = Aquarium(shark_consts, tank_consts, fish_consts, weights, beta);
            obj.positions = zeros(tank_consts.tankSize);
            obj.tankSize = tank_consts.tankSize;
            % Create shark
            shark_consts.position = ...
                randi(round(0.25*obj.tankSize),1,2) + round(0.5*obj.tankSize);
            shark_consts.tankSize = tank_consts.tankSize;
            shark = Shark(shark_consts, weights, beta);
            obj.inhabitants{1} = shark;
            obj.positions(shark.position(1),shark.position(2)) = 1;
            % Create fish shoal
            obj.fishcalculation = FishCalculation(tank_consts.tankSize);
            fishVelocity = randi(fish_consts.maxSpeed,1,2).*(1-2*(randi(2,1,2)-1));
            while norm(fishVelocity) > fish_consts.maxSpeed
                fishVelocity = randi(fish_consts.maxSpeed,1,2).*(1-2*(randi(2,1,2)-1));
            end
            for i=2:tank_consts.nrOfFish+1
                pos = randi(round(tank_consts.tankSize/4),1,2);
                while obj.positions(pos(1),pos(2)) ~= 0
                    pos = randi(round(tank_consts.tankSize/4),1,2);
                end
                obj.inhabitants{i} = Fish(pos,fishVelocity,obj.tankSize);
                obj.positions(pos(1),pos(2)) = i;
            end
        end
        
        function fitness = run(obj,draw)
            while obj.inhabitants{1}.hunting
                if rand < 0.1
                    mspeed = obj.inhabitants{2}.maxSpeed;
                    fishVelocity = randi(mspeed,1,2).*(1-2*(randi(2,1,2)-1));
                    while norm(fishVelocity) > mspeed
                        fishVelocity = randi(mspeed,1,2).*(1-2*(randi(2,1,2)-1));
                    end
                    for i=2:length(obj.inhabitants)
                        obj.inhabitants{i}.velocity = fishVelocity;
                    end
                end
                pos = zeros(obj.tankSize);
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
