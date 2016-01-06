close all

% Andreas too stupid to get proper random weight matrix another way.
yaml_path = 'constants.yml';
addpath('../lib/yamlmatlab');
C = ReadYaml(yaml_path);
nrOfGenes = 0;
inputs = 1+C.nn.nrOfInputs;
for i=1:C.nn.nrOfHiddenLayers;
    nrOfGenes = nrOfGenes + (inputs-(i-1))*(inputs-i);
end
nrOfGenes = nrOfGenes + ...
    (inputs-C.nn.nrOfHiddenLayers)*(C.nn.nrOfOutputs);
C.ga.nrOfGenes = nrOfGenes;
C.ga.mutateProb = C.ga.mutateProb*1/C.ga.nrOfGenes;

weightRange = C.nn.weightRange;
popSize = C.ga.populationSize;
nrOfGenes = C.ga.nrOfGenes;
population = rand(popSize, nrOfGenes)*2*weightRange-weightRange;


ind = population(1,:);

weights = {};
inputs = C.nn.nrOfInputs+1; % Plus 1 for threshold
outputs = C.nn.nrOfOutputs;
startP = 1;
endP = 0;
for i=1:C.nn.nrOfHiddenLayers
    endP = endP + (inputs-(i-1))*(inputs-i);
    weights{i} = reshape(ind(startP:endP),[inputs-i,inputs-(i-1)]);
    startP = endP+1;
end
last = ind(startP:end);
weights{length(weights)+1} = reshape(last,[outputs,length(last)/outputs]);




aq = Aquarium(C.shark,C.tank,C.fish,weights,C.nn.beta);

N = length(aq.fishShoal.fishes);

figure(1)
p.x = zeros(1,N);
p.y = zeros(1,N);
for i = 1:N
    p.x(i) = aq.fishShoal.fishes(i).position(1);
    p.y(i) = aq.fishShoal.fishes(i).position(2);
end
plot(p.x,p.y,'.','markersize',10);
hold on
plot(aq.shark.position(1),aq.shark.position(2),'r.','markersize',12)
axis([-100 350 -100 350])
hold off
drawnow

aq.run()


