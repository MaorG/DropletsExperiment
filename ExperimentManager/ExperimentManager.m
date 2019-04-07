classdef ExperimentManager < handle
    
    properties
       pm
       dm
       enm
       am
       om
       configFileName
       conf
<<<<<<< HEAD
       rawData
       perpData
       
=======
       rootName
       parameterSpace
>>>>>>> refs/remotes/origin/maor
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
            
            % passing info to DataManager. 
            % TODO: Perhaps can be beautified

            obj.rootName = [];
            if isfield(obj.conf, 'rootDir')
                obj.rootName = obj.conf.rootDir;
                if ~strcmp(obj.rootName(end), '\')
                    obj.rootName = [obj.rootName,'\']; 
                end
            end
            
            obj.parameterSpace = [];
            if isfield(obj.conf, 'parameterSpace')
                obj.parameterSpace = obj.conf.parameterSpace;
            end
            

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
            loadConf = obj.pm.getConfiguration([obj.rootName, obj.conf.load]);
            
            obj.dm.setRootName(obj.rootName);
            obj.dm.setExperimentParameterSpace(obj.parameterSpace);
            obj.dm.loadData(loadConf);
            
            passGlobalParameters(obj);
            
        end
                
        function passGlobalParameters(obj)
        % add global experiment parameters to all individual data entries :/
        
<<<<<<< HEAD
=======
        % funny bug (or just undocumented behaviour) - matlab converts the
        % 'global' column name into 'xGlobal'
            if isfield(obj.conf, 'xGlobal')
                for i = 1:numel(obj.dm.allData)
                    for vi = 1:2:numel(obj.conf.xGlobal)
                        obj.dm.allData(i).properties.(obj.conf.xGlobal{vi}) ...
                            = obj.conf.xGlobal{vi+1}; 
                        
                        % TODO yeah the whole properties vs params shows up
                        % here again.. a case for a class for data entry?
                        obj.dm.allData(i).parameters.(obj.conf.xGlobal{vi}) ...
                            = obj.conf.xGlobal{vi+1}; 
                    end
                end
            end
        end

        function doPrep(obj)
            prepConf = obj.pm.getConfiguration([obj.rootName, obj.conf.prep]);
            obj.dm.prepData(prepConf)
        end
        
        function doEntities(obj)
            obj.enm = EntityManager(obj.dm);
            entityConf = obj.pm.getConfiguration([obj.rootName, obj.conf.entities]);
            obj.enm.doEntities(entityConf)
        end
        
        function doAnalysis(obj)
            obj.am = AnalysisManager(obj.dm, obj.enm);
            analysisConf = obj.pm.getConfiguration([obj.rootName, obj.conf.analysis]);
            obj.am.doAnalysis(analysisConf)
        end
        
        function doOutput(obj)
            obj.om = OutputManager(obj.dm, obj.enm, obj.am);
            outputConf = obj.pm.getConfiguration([obj.rootName, obj.conf.output]);
            obj.om.doOutput(outputConf)
        end    
>>>>>>> refs/remotes/origin/maor
    end

end

    