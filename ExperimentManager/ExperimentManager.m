classdef ExperimentManager
    
    properties
       pm 
       configFileName
       conf
       rawData
       perpData
       
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
            for i = 1:numel(obj.conf.stage)
                obj.doStage(obj.conf.stage{i})
            end
        end
        
        function obj = doStage(obj, stageName)
            if (strcmp(stageName,'raw'))
                disp('raw stage');
            elseif (strcmp(stageName,'prep'))
                disp('prep stage');
            end
            
        end
        
 

            
    
        
    end

end

    