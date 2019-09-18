classdef ExperimentManager < handle
    
    properties
        pm
        dm
        enm
        am
        om
        configFileName
        conf
        rootName
        parameterSpace
        matlab_ver
        expMainTopic
        def_matlab_ver = 'maor';
        def_expMainTopic = '<main>';
    end
    
    methods
        
        function obj = ExperimentManager(matlab_ver, expMainTopic)
            obj.dm = DataManager();
            obj.pm = Parser;
            obj.enm = EntityManager(obj.dm);
            % obj.enm = EntityManager(obj.dm);
            % TODO - right now done on doEntities(), choose to delete or uncomment
            if (exist('matlab_ver', 'var'))
                obj.matlab_ver = matlab_ver;
            else
                obj.matlab_ver = obj.def_matlab_ver;
            end
            
            if (exist('expMainTopic', 'var'))
                obj.expMainTopic = expMainTopic;
            else
                obj.expMainTopic = def_expMainTopic;
            end
            
        end
        
        function configure(obj, varargin)
            
            if (length(varargin) == 1)
                obj.configFileName = varargin{1};
            else
                [userConfigFileName,path] = uigetfile('*.csv');
                obj.configFileName = [path userConfigFileName];
            end
            
            obj.conf = obj.pm.getConfiguration(obj.configFileName, '', obj.expMainTopic);
            
            
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
            
            
            loadConf = obj.pm.getConfiguration(obj.configFileName, [obj.rootName, obj.conf.load], obj.conf.load);
            
            obj.dm.setRootName(obj.rootName);
            obj.dm.setExperimentParameterSpace(obj.parameterSpace);
            obj.dm.loadData(loadConf);
            
            passGlobalParameters(obj);
            
            if (isfield(obj.conf, 'link'))
                obj.doLinking()
                obj.dm.addPropertyToAll('link', obj.conf.link); 
            end
        end
        
        % todo: should this be a func of data manager?!
        function doLinking(obj)
            
            parameters = obj.conf.parameterSpace;
            
            linkName = obj.conf.link;
            linkNameIdx = find(strcmp(parameters, linkName));
            parameters(linkNameIdx) = [];
            
            leanData = cat(1, obj.dm.allData.parameters);
            
            for i = 1:numel(leanData)
                leanData(i).linkage = struct('uID',obj.dm.allData(i).uniqueID,'order',obj.dm.allData(i).parameters.(linkName));
            end
            
%             [obj.dm.allData.nextUID] = deal([]);
%             [obj.dm.allData.prevUID] = deal([]);
            
            nd = NDResultTable(leanData, 'linkage', parameters);
            
            % TODO: could be done by "colate table" functionality of the old
            % version of NDtable?
            % TODO - another case where calling some cellfun on nd.T could
            % have been more elegant

            allDataIDs = cat(1,obj.dm.allData.uniqueID);

            for ti = 1:numel(nd.T)
                if (~isempty(nd.T{ti}))
                    entries = nd.T{ti};
                    uids = zeros(size(entries));
                    order = zeros(size(entries));
                    for ei = 1:numel(entries)
                        uids(ei) = entries{ei}.uID;
                        order(ei) = entries{ei}.order;
                    end
                    [~, idxOrder] = sort(order);
                    for oi = 2:numel(idxOrder)
                        % get allData index from uID for "current" and
                        % "prev"
                        prevSeriesIdx = idxOrder(oi-1);
                        prevDataUID = uids(prevSeriesIdx);
                        currSeriesIdx = idxOrder(oi);
                        currDataUID = uids(currSeriesIdx);
                        
                        prevAllDataIdx = find(allDataIDs == prevDataUID);
                        currAllDataIdx = find(allDataIDs == currDataUID);
                        
                        obj.dm.allData(currAllDataIdx).properties.prevUID = prevDataUID;
                        obj.dm.allData(prevAllDataIdx).properties.nextUID = currDataUID;
                        
                        % store handles for prev and next too
                        obj.dm.allData(currAllDataIdx).properties.prev = obj.dm.allData(prevAllDataIdx);
                        obj.dm.allData(prevAllDataIdx).properties.next = obj.dm.allData(currAllDataIdx);
                        
                    end
                                       
                end
                
            end
            
        end
   
        
        function passGlobalParameters(obj)
            % add global experiment parameters to all individual data entries :/
            
            
            % funny bug (or just undocumented behaviour) - matlab converts the
            % 'global' column name into 'xGlobal'
            % addition: in new parser which doesn't use readtable it
            % doesn't happen, so get global / xGlobal column, whichever is
            % there
            globCol = [];
            if isfield(obj.conf, 'xGlobal')
                globCol = 'xGlobal';
            elseif isfield(obj.conf, 'global')
                globCol = 'global';
            end
            
            if ~isempty(globCol)
                for i = 1:numel(obj.dm.allData)
                    for vi = 1:2:numel(obj.conf.(globCol))
                        obj.dm.allData(i).properties.(obj.conf.(globCol){vi}) ...
                            = obj.conf.(globCol){vi+1};
                        
                        % TODO yeah the whole properties vs params shows up
                        % here again.. a case for a class for data entry?
                        obj.dm.allData(i).parameters.(obj.conf.(globCol){vi}) ...
                            = obj.conf.(globCol){vi+1};
                    end
                end
            end
        end
        
        function doPrep(obj)
            
            prepConf = obj.pm.getConfiguration(obj.configFileName, [obj.rootName, obj.conf.prep], obj.conf.prep);
            
            obj.dm.prepData(prepConf)
        end
        
        function doEntities(obj)
            
            obj.enm = EntityManager(obj.dm);
            entityConf = obj.pm.getConfiguration(obj.configFileName, [obj.rootName, obj.conf.entities], obj.conf.entities);
            obj.enm.doEntities(entityConf)
        end
        
        function doAnalysis(obj)
            
            obj.am = AnalysisManager(obj.dm, obj.enm);
            analysisConf = obj.pm.getConfiguration(obj.configFileName, [obj.rootName, obj.conf.analysis], obj.conf.analysis);
            obj.am.doAnalysis(analysisConf)
        end
        
        function doOutput(obj)

            obj.om = OutputManager(obj.dm, obj.enm, obj.am);
            outputConf = obj.pm.getConfiguration(obj.configFileName, [obj.rootName, obj.conf.output], obj.conf.output);
            obj.om.doOutput(outputConf)
        end
        
        
        
    end
    
end

