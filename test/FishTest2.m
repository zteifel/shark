close all
clear all

%parameters
N = 30; %school size
T = 200; %tank size


% Initialize fishes and calculator
fishShoal = FishShoal(T, N, 2, 3, 10, 20);

trapPos = [80 50];

draw;



% Simulate
while(1)
    
    fishShoal.updateFishes(trapPos);
    
    
    %pause(10)
    draw;
    
end








