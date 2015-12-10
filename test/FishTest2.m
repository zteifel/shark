close all
clear all

%parameters
N = 20; %school size
T = 100; %tank size


m = T/2 - 4.5;
n = T/2 + 4.5;

% Initialize fishes and calculator
fishCalculation = FishCalculation(T);

for i = 1:N
    r = rand;
    velocity = fishCalculation.speed*[cos(2*pi*r) sin(2*pi*r)];
    position = [m+(n-m)*rand m+(n-m)*rand];
    fishes{i} = Fish(position,velocity,T);
end

draw;


% Simulate
while(1)
    
    fishCalculation.updateFishes(fishes);
    
    draw;
    
end








