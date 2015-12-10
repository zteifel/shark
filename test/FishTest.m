close all
clear all

%parameters
N = 20; %school size
T = 100; %tank size
BL = 1; %body length
delta_t = 1; %time step
r1 = .5*BL*4;
r2 = 5*BL*3;
r3 = 10*BL*3;
w = 30; %dead angle omega
speed = 1.5;

m = T/2 - 4.5;
n = T/2 + 4.5;




% Initialize fishes
for i = 1:N
    r = rand;
    velocity = speed*[cos(2*pi*r) sin(2*pi*r)];
    position = [m+(n-m)*rand m+(n-m)*rand];
    fishes{i} = Fish(position,velocity,T);
end

draw;


% Simulate
while(1)
    
    N = length(fishes);
    
    d = zeros(N,N);
    dp.x = zeros(N,N);
    dp.y = zeros(N,N);
    dp.theta = zeros(N,N);
    beta = zeros(N,N);
    new_vmag = zeros(1,N);
    closest4 = zeros(1,4);
    front4 = zeros(1,4);
    side4 = zeros(1,4);
    
    %calculate distances between fish
    %--------------------------------------------------------------------------
    for i = 1:N
        for j = 1:N
            dp.x(i,j) = fishes{j}.position(1) - fishes{i}.position(1);
            if (dp.x(i,j) < -T/2)
                dp.x(i,j) = fishes{j}.position(1) - (fishes{i}.position(1) - T);
            elseif (dp.x(i,j) > T/2)
                dp.x(i,j) = fishes{j}.position(1) - (fishes{i}.position(1) + T);
            end
            dp.y(i,j) = fishes{j}.position(2) - fishes{i}.position(2);
            if (dp.y(i,j) < -T/2)
                dp.y(i,j) = fishes{j}.position(2) - (fishes{i}.position(2) - T);
            elseif (dp.y(i,j) > T/2)
                dp.y(i,j) = fishes{j}.position(2) - (fishes{i}.position(2) + T);
            end
            dp.theta(i,j) = npi2pi(rad2deg(atan2(dp.y(i,j), dp.x(i,j))));
            d(i,j) = sqrt( dp.x(i,j)^2 + dp.y(i,j)^2 );
        end
    end
    
    
    %calculate turning angles
    %--------------------------------------------------------------------------
    for i = 1:N
        for j = 1:N
            thetaj = rad2deg(atan2(fishes{j}.velocity(2),fishes{j}.velocity(1)));
            thetai = rad2deg(atan2(fishes{i}.velocity(2),fishes{i}.velocity(1)));
            d_theta = thetaj - thetai;
            
            %repulsion zone (0 < d < r1)
            if d(i,j) > 0 && d(i,j) < r1
                plus90  = npi2pi(d_theta + 90);
                minus90 = npi2pi(d_theta - 90);
                if abs(plus90) < abs(minus90)
                    beta(i,j) = plus90;
                else beta(i,j) = minus90;
                end
            end
            
            %parallel orientation zone (r1 <= d < r2)
            if d(i,j) >= r1 && d(i,j) < r2
                beta(i,j) = npi2pi(d_theta);
            end
            
            %attraction zone (r2 <= d < r3)
            if d(i,j) >= r2 && d(i,j) < r3
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
        sorted = sort(diff_front);
        %sorted = sort(abs(dp.theta(i,:)));
        
        index = 0;
        min_i = 1; %index into sorted array that yields frontmost dp.theta
        for k = 1:N-1
            for j = 1:N
                %remove dead zone, searching zone, and self, and limit to 4
                if index < 4 && j ~= i && abs(dp.theta(i,j)) < (180 - w)...
                        && d(i,j) < r3 && abs(dp.theta(i,j)) == sorted(min_i)
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
        
        theta_old = rad2deg(atan2(fishes{i}.velocity(2),fishes{i}.velocity(1)));
        if index > 0 %at least 1 neighbor visible
            beta_avg = npi2pi(sum(beta(i,front4(1:index)))/index);
            %add randomness (normal distribution)
            sigma = 15; %standard deviation = 15 degrees
            alpha = beta_avg + sigma*randn(1);
            
            %calculate velocity vector
            theta_new = npi2pi(theta_old + alpha);
            
            
        else %no neighbors in sight -> searching
            beta_avg = npi2pi(360*rand);
            alpha = beta_avg; %no need to add normal dist.
            
            theta_new = npi2pi(theta_old + alpha);
            
        end
        
        %velocity = gamrnd(4,1/3.3)*[cosd(theta_new) sind(theta_new)];
        velocity = speed*[cosd(theta_new) sind(theta_new)];
        fishes{i}.updatePosition(velocity);
        
    end
    
    draw
    
end






