#SharkTraining
To run the Sharktraining just create an object of it  
`SharkTraining():`  
  Default options - Will save data to folder based on datetime  
                    and use constans from code/constants.yml  

The following options are available:  
* NoSaveData - SharkTraining does not save any data
* SaveFolder - Lets you specify name of data folder saved in data/
* YamlPath - Lets you specify the yaml file (can be relative) with constants.

##Examples:
`SharkTraining('NoSaveData','YamlPath','../my_own_consts.yml')`  
    Will not save data and use the constans defined in my_own_consts.yml in root folder  
`SharkTraining('SaveFolder','testdata')`  
    Using default constans.yml file and saves data to data/testdata folder.  
