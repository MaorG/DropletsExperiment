classdef DataManager < handle
    % DataManager handles all data manupulations and transformation
    % (loading, adding fields, saving)
    
    properties
        rootName
        parameterSpaceNames
        allData
        loadConfigArray
    end
    
    methods
        function obj = DataManager()
            %DataManager: Construct an instance of this class
            
            obj.allData = [];
        end
        
        function clearData(obj)
            obj.allData = [];
        end
        
        function setRootName(obj, rootName)
            
            % TODO: support linux
            if isempty(rootName)
                obj.rootName = '';
            else
                obj.rootName = rootName;
            end
        end
        
        function setExperimentParameterSpace(obj, parameterSpaceNames)
            obj.parameterSpaceNames = parameterSpaceNames;
        end
        
        function loadData(obj, loadConfigArray)
            %loadData() loads data from a struct array, one 'data' per row.
            % see loadDataRow for details
            
            % saving loadConfigArray in case there's an export 
            obj.loadConfigArray = loadConfigArray;
            
            % loading
            allData = [];
            for i = 1:numel(loadConfigArray)
                data = obj.loadDataRow(loadConfigArray(i));
                data.uniqueID = i;
                allData = [allData; data];
            end
            
            obj.allData = allData;
            
            
            
        end
        
        function data = loadDataRow(obj,loadConfigRow)
            % loadDataRow() takes a map (struct) and does the following:
            % if the value is a fileName, it 'imread's the file 
            % otherwise, it just copies the value into 
            
            readExts = {'.tif' '.tiff'}; % specifies which extensions to imread()
            
            fields = fieldnames(loadConfigRow);
            data = struct;
            for i = 1:numel(fields)
                fieldName = fields(i);
                val = loadConfigRow.(fieldName{1});
                if isnumeric(val)
                    data.properties.(fieldName{1}) = val;
                else
                    [path,name,ext] = fileparts(val);
                    if (isempty(path) || isempty(name) || isempty(ext) || ~any(strcmp(ext, readExts))) % add as plain text if the file extension is not an image
                        data.properties.(fieldName{1}) = val;
                    else
                        readPath = appendPaths(obj.rootName, [path, '\', name, ext]);
                        readPath
                        I = imread(readPath);
                        if (size(I,3)==2)
                            % TODO:
                            % why would it even get here?!?!
                            data.(fieldName{1}) = I(:,:,1);
                        else
                            data.(fieldName{1}) = I;
                        end
                    end
                end
                if sum(strcmp(obj.parameterSpaceNames, fieldName)>0)
                    data.parameters.(fieldName{1}) = data.properties.(fieldName{1});
                end
            end
        end
        
        function data = getDataByUniqueID(obj, uniqueID)
           IDs = cat(1,obj.allData.uniqueID);
           idx = IDs == uniqueID;
           data = obj.allData(idx);
        end
        
        % TODO: sort out parallel issues. 
        %       make parallel runs configurable

        function prepDataParallel(obj, prepConfig)
            disp(prepConfig)
            ad = obj.allData;
            ad2 = struct([]);
            pool = tic;
            ticBytes(gcp);
            parfor idx = 1:numel(ad)
                disp(idx)
                worker = tic;
                data = ad(idx);
                ad2 = obj.doPrepOnData(data, prepConfig);
                
                for j = 1:1e10
                    a=0;
                end
                toc(worker)
            end
            toc(pool)
            tocBytes(gcp);
            obj.allData = ad2;

        end
        
        function data = doPrepOnData(obj, data, prepConfig)
            
            for i = 1:numel(prepConfig)
                parameters = prepConfig(i).parameters;

                data.(prepConfig(i).resName) = ...
                    eval([prepConfig(i).funcName, '(data, parameters)']);
            end
        end

        
        function prepData(obj, prepConfig)
            disp(prepConfig)
            for i = 1:numel(prepConfig)
                disp(prepConfig(i));
                obj.doPrepRowOnAllData(prepConfig(i))
            end

        end
        
        function doPrepRowOnAllData(obj, prepConfigRow)
            
            if isempty(prepConfigRow.resName)
               obj.doSpecialPerpRow(prepConfigRow)
            else
                if (~isfield(obj.allData,prepConfigRow.resName))
                    [obj.allData.(prepConfigRow.resName)] = deal([]);
                end

                for i = 1:numel(obj.allData)
                    data = obj.allData(i);
                    parameters = prepConfigRow.parameters;

                    obj.allData(i).(prepConfigRow.resName) = ...
                        eval([prepConfigRow.funcName, '(data, parameters)']);
                end
            end
            
        end

        function doSpecialPerpRow(obj, prepConfigRow)
            if (strcmp(prepConfigRow.funcName, 'ExportImages'))
                doExportImages(obj, prepConfigRow)
            end
        end
        
        function doExportImages(obj, prepConfigRow)
            
            props = obj.doExportImagesParameterExtraction(prepConfigRow.parameters);
            
            allFileNames = cell(numel(props.Images), numel(obj.allData));
            for ni = 1:numel(props.Images)
                imagesFieldName = props.Images{ni};
                dstPath = props.targetDir;
            
                fileNames = obj.doFileNameingAndExport(imagesFieldName, dstPath);
                allFileNames(ni,:) = fileNames(:);
            end
            
                
             writeNewLoadFile(obj, props.Images, allFileNames, [obj.rootName, props.updatedLoad]);
        end
        
        function writeNewLoadFile(obj, fieldNames, allFileNames, loadFileName)
            
            loadConfig = obj.loadConfigArray;
            
            for ni = 1:numel(fieldNames)
                imagesFieldName = fieldNames{ni};
                [loadConfig.(imagesFieldName)] = deal(allFileNames{ni,:});
            end
            
            % big todo:
            % adding quotes to strings... better move to the parser?
            % and if so, perhaps just fix the reverse..
            % since we're only doing the load phase, it's possible the
            % "eval" stuff is unneeded.. just use isnumber
            
            allFieldNames = fieldnames(loadConfig);
            for di = 1:numel(loadConfig)
                for ni = 1:numel(allFieldNames)
                    if ~isnumeric(loadConfig(di).(allFieldNames{ni}))
                        loadConfig(di).(allFieldNames{ni}) = ['''', loadConfig(di).(allFieldNames{ni}), ''''];
                    end
                end
            end
            
            
            T = struct2table(loadConfig);
            
            writetable(T, loadFileName);
        end

        function fileNames = doFileNameingAndExport(obj, imagesFieldName, dstPath)

            if (isempty(dstPath) || dstPath(end) ~= '\') 
            	dstPath = [dstPath '\'];
            end
            
            mkdir([obj.rootName,dstPath]);
            
            dataParameters = obj.parameterSpaceNames;
            
            for di = numel(obj.allData):-1:1
                for dpi = 1:numel(dataParameters)
                    res(di).(dataParameters{dpi}) = obj.allData(di).parameters.(dataParameters{dpi});
                end
                res(di).(imagesFieldName) = obj.allData(di).(imagesFieldName);
                res(di).uid = obj.allData(di).uniqueID;
            end

            ndImage = NDResultTable(res, imagesFieldName, dataParameters);
            ndID = NDResultTable(res, 'uid', dataParameters);

            fileNames = cell(0);
            uIDs = [];
    
            % using ND table to create nice filenames, where the names are
            % determined by the parameter space, and repeats are numbered
            % - naming and actual saving of the images done 
            %   within the loop :( to avoid copying huge files
            for ti = 1:numel(ndImage.T)
                if (~isempty(ndImage.T{ti}))
                    fileName = [dstPath,imagesFieldName];
                    pindices = ndImage.Tidx{ti};
                    for pii = 1:numel(pindices)
                        % add to filename the parmaters and their values
                        fileName = strjoin({fileName,ndImage.names{pii},ndImage.strvals{pii}{ndImage.Tidx{ti}(pii)}});
                    end
                    for ri = 1:numel(ndImage.T{ti})
                        % add repeat index (for identical entries)
                        final_fileName = strjoin({fileName,num2str(ri)});

                        % add repeat index (for identical entries)
                        final_fileName = strjoin({final_fileName,'.tif'});
                        
                        final_uID = ndID.T{ti}{ri};
                        
                        fileNames = [fileNames, final_fileName];
                        uIDs = [uIDs, final_uID];
                        
                        imwrite(ndImage.T{ti}{ri}, [obj.rootName, final_fileName]);
                    end
                end
            end
            
            [~,idOrder] = sort(uIDs);
            fileNames = fileNames(idOrder);

        end
        
        function props = doExportImagesParameterExtraction(obj, v)

            props = struct(...
                'Images', {'R'},...
                'targetDir', 'new tif\',...
                'updatedLoad', 'newload.csv');

            for i = 1:numel(v)

                if (strcmp(v{i}, 'Images'))
                    props.Images = v{i+1};
                elseif (strcmp(v{i}, 'targetDir'))
                    props.targetDir = v{i+1};
                elseif (strcmp(v{i}, 'updatedLoad'))
                    props.updatedLoad = v{i+1};
                end
            end

        end
        
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    *sketch* for parallelization
%%%%    - performance should be tested!
%%%%    - useful for EntityManager as well


        function doPrepRowOnAllDataParallel(obj, prepConfigRow)
            
            [obj.allData.(prepConfigRow.resName)] = deal([]);
            
            allData = obj.allData;
            results = cell(numel(allData),1);
            
            parfor i = 1:numel(allData)
                data = allData(i);
                parameters = prepConfigRow.parameters;

                results{i} = ...
                    eval([prepConfigRow.funcName, '(data, parameters)']);
            end
        end
        
        function filteredData = filterData(obj, filter)
                        
            filteredData = [];
            filterPairs = reshape(filter,2,numel(filter)/2)';
            
            for di = 1:numel(obj.allData)
                toKeep = 1;
                for fi = 1:size(filterPairs,1)
                    if isfield(obj.allData(di).parameters, filterPairs{fi,1})
                        if isnumeric(obj.allData(di).parameters.(filterPairs{fi,1}))
                            if sum(obj.allData(di).parameters.(filterPairs{fi,1}) == filterPairs{fi,2}{1}) == 0
                                toKeep = 0;
                            end
                        else
                            if sum(contains(obj.allData(di).parameters.(filterPairs{fi,1}), filterPairs{fi,2})) == 0
                                toKeep = 0;
                            end
                        end
                    end
                end
                if (toKeep)
                    filteredData = [filteredData, obj.allData(di)];
                end
            end
            
            
        end
    end
end

