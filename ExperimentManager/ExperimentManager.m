classdef ExperimentManager < handle
    
    properties
       pm
       dm
       configFileName
       conf
       rawData
       perpData
       
    end
    
    methods
        
        function obj = ExperimentManager(obj)
            obj.dm = DataManager;
            obj.pm = Parser;
            [configFileName,path] = uigetfile('*.csv');
            obj.configFileName = [path configFileName];
        end
        
        function configure(obj)
            

            obj.conf = obj.pm.getConfiguration(obj.configFileName);

        end
        
        function doWork(obj)
            for i = 1:numel(obj.conf.stage)
                obj.doStage(obj.conf.stage{i})
            end
        end
        
        function doStage(obj, stageName)
            if (strcmp(stageName,'load'))
                obj.doLoad()
            elseif (strcmp(stageName,'prep'))
                disp('prep stage');
            end
            
        end
        
        function doLoad(obj)
            
            loadConf = obj.pm.getConfiguration(obj.conf.load);
            
            obj.dm.loadData(loadConf)
            
        end
        
    end

end

    