classdef FishShoal
    
    properties
        
        T = 100; %tank size
        fishes;
        driftSpeed;
        maxSpeed;
        dv;
        shoalSize;
        attractionDistance;
        r1;
        r2;
        
    end
    
    
    
    properties (Constant = true)
        
        
        w = 30; %dead angle omega
        frontOffset = 0; % KEEP AT 0!
        
    end
    
    
    methods
        
        function obj = FishShoal(tankSize, shoalSize, driftSpeed, maxSpeed, ...
                scareDistance, attractionDistance, accelerationRate)
            
            obj.T = tankSize;
            obj.driftSpeed = driftSpeed;
            obj.maxSpeed = maxSpeed;
            obj.dv = driftSpeed*0.2;
            obj.shoalSize = shoalSize;
            obj.attractionDistance = attractionDistance;
            obj.r1 = attractionDistance / 5;
            obj.r2 = attractionDistance / 2;
            
            m = tankSize/2 - 4.5;
            n = tankSize/2 + 4.5;
            for i = 1:shoalSize
                r = rand;
                velocity = obj.driftSpeed*[cos(2*pi*r) sin(2*pi*r)];
                position = [m+(n-m)*rand m+(n-m)*rand];
                fish = Fish(position,velocity,tankSize,scareDistance,...
                    maxSpeed,accelerationRate);
                obj.fishes = [obj.fishes fish];
            end
        end
        
        function updateFishes(obj,predatorPosition)
            
            
            N = length(obj.fishes);
            
            d = zeros(N,N);
            dp.x = zeros(N,N);
            dp.y = zeros(N,N);
            dp.theta = zeros(N,N);
            beta = zeros(N,N);
            
            positions = zeros(length(obj.fishes),2);
            for i = 1:length(obj.fishes)
                positions(i,:) = obj.fishes(i).positionReal;
            end
            averagePosition = mean(positions);
            %calculate distances between fish
            %--------------------------------------------------------------------------
            
            dp.x = transpose(positions(:,1)*ones(1,N)) - positions(:,1)*ones(1,N);
            dp.y = transpose(positions(:,2)*ones(1,N)) - positions(:,2)*ones(1,N);
            
            dp.theta = npi2pi(rad2deg(atan2(dp.y, dp.x)));
            
            d = sqrt(dp.x.^2 + dp.y.^2);
            
            
            velocities = zeros(length(obj.fishes),2);
            for i = 1:length(obj.fishes)
                velocities(i,:) = obj.fishes(i).velocityReal;
            end
            %calculate turning angles
            %--------------------------------------------------------------------------
            for i = 1:N
                for j = 1:N
                    thetaj = rad2deg(atan2(obj.fishes(j).velocityReal(2),obj.fishes(j).velocityReal(1)));
                    thetai = rad2deg(atan2(obj.fishes(i).velocityReal(2),obj.fishes(i).velocityReal(1)));
                    d_theta = thetaj - thetai;
                    
                    %repulsion zone (0 < d < r1)
                    if d(i,j) > 0 && d(i,j) < obj.r1
                        plus90  = npi2pi(d_theta + 90);
                        minus90 = npi2pi(d_theta - 90);
                        if abs(plus90) < abs(minus90)
                            beta(i,j) = plus90;
                        else beta(i,j) = minus90;
                        end
                    end
                    %parallel orientation zone (r1 <= d < r2)
                    if d(i,j) >= obj.r1 && d(i,j) < obj.r2
                        beta(i,j) = npi2pi(d_theta);
                    end
                    %attraction zone (r2 <= d < attractionDistance)
                    if d(i,j) >= obj.r2 && d(i,j) < obj.attractionDistance
                        beta(i,j) = npi2pi(dp.theta(i,j) - thetai);
                    end
                end
            end
            
            % beta = transpose(rad2deg(atan2(velocities(:,1),velocities(:,2))*ones(N))) - ...
            % rad2deg(atan2(velocities(:,1),velocities(:,2))*ones(N));
            
            
            %distance priority - average closest 4 neighbors (with dead zone)
            
            %find indices of closest 4 neighbors
            temp = zeros(1,N-1);
            for i = 1:N
                
                % Far from center
                if (norm(averagePosition - obj.fishes(i).positionReal) > obj.attractionDistance)
                    theta_new = rad2deg(atan2(averagePosition(2) - obj.fishes(i).positionReal(2),...
                        averagePosition(1) - obj.fishes(i).positionReal(1)));
                    velocityReal = obj.driftSpeed*[cosd(theta_new) sind(theta_new)];
                else
                    
                    index = 0;
                    diff_p = d(i,:);
                    %remove self
                    for j = 1:N
                        if j ~= i
                            index = index + 1;
                            temp(index) = diff_p(j);
                        end
                    end
                    diff_p = temp;
                    sorted = sort(diff_p);
                    %sorted = sort(d(i,:));
                    
                    index = 0;
                    min_i = 1; %index into sorted array that yields smallest d
                    for k = 1:N-1
                        for j = 1:N
                            %remove dead zone, searching zone, and self, and limit to 4
                            if index < 4 && j ~= i && abs(dp.theta(i,j)) < (180 - obj.w)...
                                    && d(i,j) < obj.attractionDistance && d(i,j) == sorted(min_i)
                                index = index + 1;
                                closest4(index) = j;
                                %increment min index -> index of next smallest d
                                min_i = min_i + 1;
                            end
                        end
                    end
                    
                    theta_old = rad2deg(atan2(obj.fishes(i).velocityReal(2),obj.fishes(i).velocityReal(1)));
                    
                    if index > 0 %at least 1 neighbor sensed
                        beta_avg = npi2pi(sum(beta(i,closest4(1:index)))/index);
                        %add randomness (normal distribution)
                        sigma = 15; %standard deviation = 15 degrees
                        alpha = beta_avg + sigma*randn(1);
                        
                        theta_new = npi2pi(theta_old + alpha);
                        
                    else %no neighbors in sensory range -> searching
                        beta_avg = npi2pi(360*rand);
                        alpha = beta_avg; %no need to add normal dist.
                        theta_new = npi2pi(theta_old + alpha);
                    end
                    
                    velocityReal = (obj.driftSpeed + obj.dv*randn(1)) * ...
                        [cosd(theta_new) sind(theta_new)];
                end
                
                obj.fishes(i).updatePosition(velocityReal, predatorPosition);
                
            end
            
        end
        
    end
    
    
end