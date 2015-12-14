classdef SharkTraining

  properties
    save_path               % Folder name to save output to
    save_data = true;       % If false, no data will be saved
    stop = false;
    C                       % Struct to hold constants loaded from yaml file
    population
    fitness_fig
    % Test solution
    goal
  end

  methods
    % Constructor
    function obj = SharkTraining(varargin)
      yaml_path = 'constants.yml';
      folder_name = datestr(datetime('now'),'ddmmyy_HH:MM');
      for i=1:length(varargin)
        switch varargin{i}
        case 'SaveFolder'
            folder_name = varargin{i+1};
        case 'YamlPath'
            yaml_path = varargin{i+1};
        case 'NoSaveData'
            obj.save_data = false;
        end
      end
      if obj.save_data
        obj.save_path = obj.savePath(folder_name);
      end
      obj.C = obj.importConstantsFromFile(yaml_path);
      obj.fitness_fig = obj.initFitnessFigure();

      % Start algorithm
      obj.population = obj.initializePopulation();
      obj.goal = rand(1,obj.C.ga.nrOfGenes);
      obj.startTraining();
    end

    %%%%%% GA methods %%%%%%%%%%%

    function startTraining(obj)
      h = guidata(obj.fitness_fig);
      count = 0;

      fitnessHist = zeros(10^5,1);
      while not(h.stoptraining)
        drawnow;
        h = guidata(obj.fitness_fig);
        count = count + 1;

        disp(sprintf('============== Gen %d ==============',count));  
        % Evaluate all chromosomes
        fitness = zeros(obj.C.ga.populationSize,1);
        parfor i=1: obj.C.ga.populationSize
          fitness(i) = obj.evalChromosome(obj.population(i,:));
          disp(sprintf( ...
            'Ind %i(%i), Fitness: %i',i,obj.C.ga.populationSize,fitness(i)));
        end

        tempPopulation = obj.population;
        % Selection and Crossover
        for i=1:2:obj.C.ga.populationSize
          i1 = obj.tournamentSelect(fitness);
          i2 = obj.tournamentSelect(fitness);
          ind1 = obj.population(i1,:);
          ind2 = obj.population(i2,:);

          if rand < obj.C.ga.crossProb
            [ind1, ind2] = obj.cross(ind1,ind2);
          end
          tempPopulation(i,:) = ind1;
          tempPopulation(i+1,:) = ind2;
        end

        % Mutation
        for i=1:obj.C.ga.populationSize
          ind = tempPopulation(i,:);
          mutatedInd = obj.mutate(ind);
          tempPopulation(i,:) = mutatedInd;
        end

        % Elite Insert
        [bestFitness, iBestInd] = max(fitness);
        bestInd = obj.population(iBestInd,:);
        tempPopulation = obj.insertBestInd(tempPopulation,bestInd);

        obj.population = tempPopulation;
        fitnessHist(count) = bestFitness;
        bestWeights = obj.decodeChromosome(bestInd);
        obj.updateFig(fitnessHist(1:count));
        if obj.save_data
          obj.save_weights(bestWeights,bestFitness,count);
        end
      end
      if obj.save_data
        obj.saveConstants();
        obj.saveFitnessHist(fitnessHist(1:count));
        disp(sprintf('Data saved to folder %s',fullfile(pwd,obj.save_path)));
      end
    end

    function elitePop = insertBestInd(obj,population, ind)
        nInserts = obj.C.ga.eliteInserts;
        elitePop = population;
        modifiedPopulation(1:nInserts,:) = ones(nInserts,1)*ind;
    end

    function [newInd1, newInd2] = cross(obj,ind1,ind2);
        crossPos = floor(rand*length(ind1));
        newInd1 = [ind1(1:crossPos) ind2(crossPos+1:end)];
        newInd2 = [ind2(1:crossPos) ind1(crossPos+1:end)];
    end

    function mutatedInd = mutate(obj,ind)
      mutatedInd = ind;
      weightRange = obj.C.nn.weightRange;
      for j = 1:obj.C.ga.nrOfGenes
        if rand < obj.C.ga.mutateProb
          newInd = ind(j)+obj.C.ga.creepRate*weightRange*randn;
          if newInd > weightRange
            mutatedInd(j) = weightRange;
          elseif newInd < -weightRange
            mutatedInd(j) = -weightRange;
          else
            mutatedInd(j) = newInd;
          end
        end
      end
    end

    function weights = decodeChromosome(obj,ind)
      weights = {};
      inputs = obj.C.nn.nrOfInputs+1; % Plus 1 for threshold
      outputs = obj.C.nn.nrOfOutputs;
      startP = 1;
      endP = 0;
      for i=1:obj.C.nn.nrOfHiddenLayers
        endP = endP + (inputs-(i-1))*(inputs-i);
        weights{i} = reshape(ind(startP:endP),[inputs-i,inputs-(i-1)]);
        startP = endP+1;
      end
      last = ind(startP:end);
      weights{length(weights)+1} = reshape(last,[outputs,length(last)/outputs]);
    end

    function winner = tournamentSelect(obj,fitness)
      popSize = obj.C.ga.populationSize;
      tourSize = obj.C.ga.tournamentSize;
      tourProb = obj.C.ga.tournamentProb;

      competitors = floor(rand(tourSize,1)*popSize)+1;
      for i = 1: obj.C.ga.tournamentSize-1
        [~, strongest] = max(fitness(competitors));
        if rand < tourProb
          winner = competitors(strongest);
          return
        else
          competitors(strongest) = [];   % Remove the strongest.
        end
      end
      winner = competitors(1); % Return the only one left.
    end

    function fitness = evalChromosome(obj,individual);
      weights = obj.decodeChromosome(individual);
      sharktank = ...
        Aquarium(obj.C.shark,obj.C.tank,obj.C.fish,weights,obj.C.nn.beta);
      fitness = sharktank.run(0);
      % Uncomment if testing without Aquarium
      % nrOfFishEaten = ...
      %  1-sum(abs(obj.goal-individual))/ ...
      %     (2*obj.C.nn.weightRange*obj.C.ga.nrOfGenes);
    end

    function population = initializePopulation(obj);
      weightRange = obj.C.nn.weightRange;
      popSize = obj.C.ga.populationSize;
      nrOfGenes = obj.C.ga.nrOfGenes;
      population = rand(popSize, nrOfGenes)*2*weightRange-weightRange;
    end

    %%%%%%%  Helpers %%%%%%%%%%%%%

    function stopTraining(obj,src,eventData)
      disp('Training stopped! Wait for generation to finish...');
      h = guidata(src.Parent);
      h.stoptraining = true;
      guidata(src.Parent,h);
    end

    function fig = initFitnessFigure(obj)
      fig = figure();
      pl = plot(1:1,'k');
      uicontrol('Style', 'pushbutton', ...
                'String','Stop training', ...
                'Position',[ 10 10 110 20], ...
                'Callback', @obj.stopTraining)

      xlabel('Generation');
      ylabel('Fish caught');
      title('Evolution of best in generation shark');
      h = guidata(fig);
      h.stoptraining = false;
      h.sharktrain = obj;
      h.pl = pl;
      guidata(fig,h);
    end

    function updateFig(obj,fitness)
        h = guidata(obj.fitness_fig);
        pl = h.pl;
        pl.YData = fitness;
        drawnow;
    end

    function saveConstants(obj)
      yml_file = fullfile(obj.save_path,'constants.yml');
      WriteYaml(yml_file,obj.C);
    end

    function saveFitnessHist(obj,fitness)
      mat_file = fullfile(obj.save_path,'fitness_hist.mat');
      save(mat_file,'fitness');
    end

    function success = save_weights(obj,weights,fitness,gen)
      mat_file = [obj.save_path sprintf('/weights_%d.mat',gen)];
      save(mat_file,'weights','fitness');
    end

    function constants = importConstantsFromFile(obj, yaml_path)
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
      constants = C;
    end

    function save_path = savePath(obj,folder_name)
      if exist('../data') ~= 7
          mkdir('../data')
      end
      save_path = fullfile('../data',folder_name);
      if exist(save_path) == 7
          err = MException(...
              'SharkTraining:DataFolderExist', ...
              sprintf('Data folder %s already exist',save_path));
          err.throw();
      else
          mkdir(save_path)
      end
    end

  end
end
