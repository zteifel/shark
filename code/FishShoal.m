classdef FishShoal
    
    properties
        
        T = 100; %tank size
        fishes;
        
    end
    
    
    
    properties (Constant = true)
        
        r1 = 2;
        r2 = 10;
        r3 = 30;
        w = 30; %dead angle omega
        frontOffset = 0; % KEEP AT 0!
        speed = 2;
        
    end
    
    
    methods
        
        function obj = FishShoal(tankSize, shoalSize, maxSpeed)
            obj.T = tankSize;
            
            m = tankSize/2 - 4.5;
            n = tankSize/2 + 4.5;
            for i = 1:shoalSize
                r = rand;
                velocity = obj.speed*[cos(2*pi*r) sin(2*pi*r)];
                position = [m+(n-m)*rand m+(n-m)*rand];
                obj.fishes{i} = Fish(position,velocity,tankSize,maxSpeed);
            end
        end
        
        function updateFishes(obj,predatorPosition)
            
            
            N = length(obj.fishes)-1;
            
            d = zeros(N,N);
            dp.x = zeros(N,N);
            dp.y = zeros(N,N);
            dp.theta = zeros(N,N);
            beta = zeros(N,N);
            front4 = zeros(1,4);
            
            %calculate distances between fish
            %--------------------------------------------------------------------------
            for i = 1:N
                for j = 1:N
                    dp.x(i,j) = obj.fishes{j}.positionReal(1) - obj.fishes{i}.positionReal(1);
                    if (dp.x(i,j) < -obj.T/2)
                        dp.x(i,j) = obj.fishes{j}.positionReal(1) - (obj.fishes{i}.positionReal(1) - obj.T);
                    elseif (dp.x(i,j) > obj.T/2)
                        dp.x(i,j) = obj.fishes{j}.positionReal(1) - (obj.fishes{i}.positionReal(1) + obj.T);
                    end
                    dp.y(i,j) = obj.fishes{j}.positionReal(2) - obj.fishes{i}.positionReal(2);
                    if (dp.y(i,j) < -obj.T/2)
                        dp.y(i,j) = obj.fishes{j}.positionReal(2) - (obj.fishes{i}.positionReal(2) - obj.T);
                    elseif (dp.y(i,j) > obj.T/2)
                        dp.y(i,j) = obj.fishes{j}.positionReal(2) - (obj.fishes{i}.positionReal(2) + obj.T);
                    end
                    dp.theta(i,j) = npi2pi(rad2deg(atan2(dp.y(i,j), dp.x(i,j))));
                    d(i,j) = sqrt( dp.x(i,j)^2 + dp.y(i,j)^2 );
                end
            end
            
            
            %calculate turning angles
            %--------------------------------------------------------------------------
            for i = 1:N
                for j = 1:N
                    thetaj = rad2deg(atan2(obj.fishes{j}.velocityReal(2),obj.fishes{j}.velocityReal(1)));
                    thetai = rad2deg(atan2(obj.fishes{i}.velocityReal(2),obj.fishes{i}.velocityReal(1)));
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
                    
                    %attraction zone (r2 <= d < r3)
                    if d(i,j) >= obj.r2 && d(i,j) < obj.r3
                        beta(i,j) = npi2pi(dp.theta(i,j) - thetai);
                    end
                end
            end
            
            
            %front priority - average frontmost 4 neighbors (with dead zone)
            temp = zeros(1,N-1);
            for i = 1:N
                index = 0;
                diff_front = abs(dp.theta(i,:));
                %remove self
                for j = 1:N
                    if j ~= i
                        index = index + 1;
                        temp(index) = diff_front(j);
                    end
                end
                diff_front = temp;
                sorted = sort(abs(diff_front-obj.frontOffset));
                
                %sorted = sort(abs(dp.theta(i,:)));
                
                
                
                index = 0;
                min_i = 1; %index into sorted array that yields frontmost dp.theta
                for k = 1:N-1
                    for j = 1:N
                        
                        %remove dead zone, searching zone, and self, and limit to 4
                        if index < 4 && j ~= i && dp.theta(i,j) < (180 - obj.w + obj.frontOffset) ...
                                && dp.theta(i,j) > (-180 + obj.w + obj.frontOffset) ...
                                && d(i,j) < obj.r3 && abs(abs(dp.theta(i,j)) - obj.frontOffset) == sorted(min_i)
                            index = index + 1;
                            front4(index) = j;
                            %increment min index -> index of next frontmost dp.theta
                            min_i = min_i + 1;
                        end
                    end
                end
                %         for k = 1:N
                %             if index < 4 && k ~= i && abs(dp.theta(i,j)) < (180 - w)...
                %                 && d(i,j) < r3 && abs(dp.theta(i,j)) == sorted(k)
                %             front4(index + 1) = j;
                %             index = index + 1;
                %         end
                
                theta_old = rad2deg(atan2(obj.fishes{i}.velocityReal(2),obj.fishes{i}.velocityReal(1)));
                if index > 0 %at least 1 neighbor visible
                    beta_avg = npi2pi(sum(beta(i,front4(1:index)))/index);
                    
                    %add randomness (normal distribution)
                    sigma = 15; %standard deviation = 15 degrees
                    alpha = beta_avg + sigma*randn(1);
                    
                    %calculate velocityReal vector
                    theta_new = npi2pi(theta_old + alpha);
                    
                    
                else %no neighbors in sight -> searching
                    beta_avg = npi2pi(360*rand);
                    alpha = beta_avg; %no need to add normal dist.
                    
                    theta_new = npi2pi(theta_old + alpha);
                    
                end
                
                %velocityReal = gamrnd(4,1/3.3)*[cosd(theta_new) sind(theta_new)];
                velocityReal = obj.speed*[cosd(theta_new) sind(theta_new)];
                obj.fishes{i}.updatePosition(velocityReal,predatorPosition);
                
            end
            
            
        end
        
    end
    
    
end