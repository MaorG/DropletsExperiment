classdef ExperimentManager < handle
    
    properties
       pm
       dm
       enm
       am
       om
       configFileName
       conf
    end
    
    methods
        
        function obj = ExperimentManager(obj)
            obj.dm = DataManager;
            obj.pm = Parser;
            obj.enm = EntityManager(obj.dm);
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
            
            passGlobalParameters(obj);
            
        end
        
        function passGlobalParameters(obj)
        % add experiment parameters to all individual data entries :/
            for i = 1:numel(obj.dm.allData)
                for vi = 1:2:numel(obj.conf.parameters)
                    obj.dm.allData(i).params.(obj.conf.parameters{vi}) ...
                        = obj.conf.parameters{vi+1};        
                end
            end
        end

        function doPrep(obj)
            prepConf = obj.pm.getConfiguration(obj.conf.prep);
            obj.dm.prepData(prepConf)
        end
        
        function doEntities(obj)
            %obj.enm = EntityManager(obj.dm);
            entityConf = obj.pm.getConfiguration(obj.conf.entities);
            obj.enm.doEntities(entityConf)
        end
        
        function doAnalysis(obj)
            obj.am = AnalysisManager(obj.dm, obj.enm);
            analysisConf = obj.pm.getConfiguration(obj.conf.analysis);
            obj.am.doAnalysis(analysisConf)
        end
        
        function doOutput(obj)
            obj.om = OutputManager(obj.dm, obj.enm, obj.am);
            outputConf = obj.pm.getConfiguration(obj.conf.output);
            obj.om.doOutput(outputConf)
        end    
    end

end

    