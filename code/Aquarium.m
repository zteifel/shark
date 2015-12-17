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
            obj.fishShoal = FishShoal(tank_consts.tankSize, tank_consts.nrOfFish, fish_consts.maxSpeed);
        end

        function fitness = run(obj,draw)
            while obj.shark.hunting
                obj.fishShoal.updateFishes(obj.shark.position);
                obj.fishShoal.fishes = obj.shark.updatePosition(obj.fishShoal.fishes);
            end
            fitness = (obj.shark.fishEaten/obj.shark.energy);
        end
    end

end
