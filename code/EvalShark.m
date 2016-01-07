function EvalShark(varargin)
  for i=1:length(varargin)
    switch varargin{i}
      case 'DataDir'
        folder_name = varargin{i+1};
      case 'MaxEnergy'
        maxEnergy = varargin{i+1};
      case 'NrOfTrials'
        nrOfTrials = varargin{i+1};
      case 'WeightGeneration'
        weightGen = varargin{i+1};
    end

  end

  datadir =  dir('../data');

  if not(exist('folder_name','var'))
    folder_name = fullfile('../data', datadir(end).name);
  end
  if not(exist('nrOfTrials','var'))
    nrOfTrials = 1;
  end
  if not(exist('weightGen'))
    load(fullfile(folder_name, 'fitness_hist.mat'));
    weightGen = length(fitness);
  end

  weights_file = fullfile(folder_name, sprintf('weights_%d.mat',weightGen));
  load(weights_file);
  if not(exist('weights','var'))
    disp(sprintf('No weight variable in file %s!',weights_file));
    return
  else
    disp(sprintf('Loading weights from %s...',weights_file));
  end
  constant_file = fullfile(folder_name, 'constants.yml');
 
  % Create SharkTraining
  st = SharkTraining('NoSaveData','NoTraining');
  if exist('maxEnergy','var')
    st.C.shark.maxEnergy = maxEnergy;
  end

  fitness = zeros(nrOfTrials,2); 
  for i=1:nrOfTrials
    ANNtank = Aquarium(st.C.shark,st.C.tank,st.C.fish,weights,st.C.nn.beta,true);
    AItank = Aquarium(st.C.shark,st.C.tank,st.C.fish,[],[],true);
    fitness(i,1) = ANNtank.run(); 
    fitness(i,2) = AItank.run()
  end
  if nrOfTrials > 1
    meanFitness = mean(fitness);
    varFitness = var(fitness);
  else
    meanFitness = fitness;
    varFitness = [0 0];
  end
  disp(sprintf( ...
    'Max Energy: %i\n ANN-fitness: %.3f(%.3f)\nAI-fitness: %.3f(%.3f)', ...
    st.C.shark.maxEnergy, ...
    meanFitness(1),varFitness(1), ...
    meanFitness(2),varFitness(2)));
                

end 
