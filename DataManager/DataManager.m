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
        
        function loadData(obj, loadConfigArray)
            %loadData() loads data from a struct array, one 'data' per row.
            % see loadDataRow for details
            allData = [];
            for i = 1:numel(loadConfigArray)
                data = obj.loadDataRow(loadConfigArray(i));
                allData = [allData; data];
            end
            
            obj.allData = allData;
        end
        
        function data = loadDataRow(obj,loadConfigRow)
            %loadDataRow() takes a map (struct) and does the following:
            % if the value is a fileName, it 'imread's the file
            % otherwise, it just copies the value
            
            fields = fieldnames(loadConfigRow);
            data = struct;
            for i = 1:numel(fields)
                fieldName = fields(i)
                val = loadConfigRow.(fieldName{1});
                if isnumeric(val)
                    data.(fieldName{1}) = val;
                else
                    [path,name,ext] = fileparts(val);
                    if (isempty(path) || isempty(name) || isempty(ext))
                        data.(fieldName{1}) = val;
                    else
                        I = imread([path,'\',name,ext]);
                        data.(fieldName{1}) = I;
                    end
                end
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
            
            [obj.allData.(prepConfigRow.resName)] = deal([]);
            for i = 1:numel(obj.allData)
                data = obj.allData(i);
                parameters = prepConfigRow.parameters;

                obj.allData(i).(prepConfigRow.resName) = ...
                    eval([prepConfigRow.funcName, '(data, parameters)']);
            end
        end
    end
end

