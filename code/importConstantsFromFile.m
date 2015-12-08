function constants = importConstantsFromFile(yaml_path)
  addpath('../lib/yamlmatlab'); 
  C = ReadYaml(yaml_path);

  nrOfGenes = 0;
  for i=1:C.nn.nrOfHiddenLayers;
    nrOfGenes = nrOfGenes + (C.nn.nrOfInputs-(i-1))*(C.nn.nrOfInputs-i);
  end
  nrOfGenes = nrOfGenes + ...
      (C.nn.nrOfInputs-C.nn.nrOfHiddenLayers)*(C.nn.nrOfOutputs);
  C.ga.nrOfGenes = nrOfGenes;
  C.ga.mutateProb = C.ga.mutateProb*1/C.ga.nrOfGenes;
  constants = C;
end
