classdef DataManager < handle
    % DataManager handles all data manupulations and transformation
    % (loading, adding fields, saving)
    
    properties
        allData
    end
    
    methods
        function obj = DataManager()
            %DataManager: Construct an instance of this class
            
            obj.allData = [];
        end
        
        function clearData(obj)
            obj.allData = [];
        end
        
        function loadData(obj, loadConfigArray)
            %loadData() loads data from a struct array, one 'data' per row.
            % see loadDataRow for details
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
            % otherwise, it just copies the value
            
            fields = fieldnames(loadConfigRow);
            data = struct;
            for i = 1:numel(fields)
                fieldName = fields(i)
                val = loadConfigRow.(fieldName{1});
                if isnumeric(val)
                    data.params.(fieldName{1}) = val;
                else
                    [path,name,ext] = fileparts(val);
                    if (isempty(path) || isempty(name) || isempty(ext))
                        data.params.(fieldName{1}) = val;
                    else
                        I = imread([path,'\',name,ext]);
                        if (size(I,3)==2)
                            % TODO:
                            % why would it even get here?!?!
                            data.(fieldName{1}) = I(:,:,1);
                        else
                            data.(fieldName{1}) = I;
                        end
                    end
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
                    if isfield(obj.allData(di).params, filterPairs{fi,1})
                        if sum(contains(obj.allData(di).params.(filterPairs{fi,1}), filterPairs{fi,2})) == 0
                            toKeep = 0;
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

