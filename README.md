#SharkTraining
To run the Sharktraining just create an object of it  
`SharkTraining():`  
  Default options - Will save data to folder based on datetime  
                    and use constans from code/constants.yml  

The following options are available:  
* NoSaveData - SharkTraining does not save any data
* SaveFolder - Lets you specify name of data folder saved in data/
* YamlPath - Lets you specify the yaml file (can be relative) with constants.
* VisualizeTraining - Show the training taking place

##Examples:
`SharkTraining('NoSaveData','YamlPath','../my_own_consts.yml')`  
    Will not save data and use the constans defined in my_own_consts.yml in root folder  
`SharkTraining('SaveFolder','testdata')`  
    Using default constans.yml file and saves data to data/testdata folder.  

##EvalShark()
This scripts lets you evaluate a shark and compare it to the AI shark given  

Parameters:
* DataDir - The directory where the weights are save (default: the latest folder in data dir)
* MaxEnergy - Lets you specifiy the amount of energy the shark has to spend (default: Same as inte training)
* NrOfTrials - Specify the number of trials that the fitness is calculated as a mean of (default: 1)
* WeightGeneration - Specifiy the generation in training to pick weights from (Default: last generation)  

The value is given as mean fitness value with variance in parenthesis

