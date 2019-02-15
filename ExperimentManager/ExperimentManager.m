classdef ExperimentManager
    
    properties
       pm 
       configFileName
       conf
    end
    
    methods
        
        function obj = ExperimentManager(obj)
            obj.pm = Parser;
            [configFileName,path] = uigetfile('*.csv');
            obj.configFileName = [path configFileName];
        end
        
        function obj = configure(obj)
            

            obj.conf = obj.pm.getConfiguration(obj.configFileName);

        end
        
        function obj = doWork(obj)
            for i = 1:numel(conf.stage)
                doStage(conf.stage{i})
            end
        end
        
        function obj = doStage(obj, stageName)
            
        end
        
 

            
    
        
    end

end

    