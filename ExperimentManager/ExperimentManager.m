classdef ExperimentManager < handle
    
    properties
       pm
       dm
       enm
       configFileName
       conf
    end
    
    methods
        
        function obj = ExperimentManager(obj)
            obj.dm = DataManager;
            obj.pm = Parser;
            % obj.enm = EntityManager(obj.dm);
            % TODO - right now done on doEntities(), choose to delete or uncomment
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
                obj.doPerp()
            end
            
        end
        
        function doLoad(obj)
            
            loadConf = obj.pm.getConfiguration(obj.conf.load);
            
            obj.dm.loadData(loadConf)
            
        end
        
        function doPrep(obj)
            
            prepConf = obj.pm.getConfiguration(obj.conf.prep);
            
            obj.dm.prepData(prepConf)
            
        end
        
        function doEntities(obj)
            obj.enm = EntityManager(obj.dm);
            entityConf = obj.pm.getConfiguration(obj.conf.entities);
            
            obj.enm.doEntities(entityConf)
            
        end
    end

end

    