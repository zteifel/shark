close all
clear all

%parameters
N = 30; %school size
T = 100; %tank size


% Initialize fishes and calculator
fishShoal = FishShoal(T, N, 2, 3, 10);

trapPos = [80 50];

%draw;



% Simulate
while(1)
    tic
    fishShoal.updateFishes(trapPos);
    toc
    
    pause(10)
    draw;
    
end








