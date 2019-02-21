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
                fieldName = fields(i);
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
            
            parameters = prepConfigRow.parameters;
            
            [obj.allData.(prepConfigRow.resName)] = deal([]);
            for i = 1:numel(obj.allData)
                data = obj.allData(i);

                obj.allData(i).(prepConfigRow.resName) = ...
                    eval([prepConfigRow.funcName, '(data, parameters)']);
            end
        end
                
        function writeData(obj, folderPath, ext, csvFile, saveFields)
            
            % folderPath - the main folder to save the data to
            % ext - extension of the image files to be saved in the
            % subfolders (1,2,3,...) of the main folder
            % csvFile - the csv file with the data structure that will be
            % written to the main folder
            % fields - optional, writes only the specified fields (defined
            % as a cell array of strings); if not specified or empty - writes all
            % fields
            
            fields = fieldnames(obj.allData);
            
            savedData = struct;
            
            for i = 1:numel(obj.allData)
                dataRow = obj.allData(i);
                
                for ii = 1:numel(fields)
                    fieldName = fields(ii);
                    fieldName = fieldName{1};
                    
                    if ~exist('saveFields', 'var') || isempty(saveFields) || any(strcmp(saveFields, fieldName))
                        val = dataRow.(fieldName);
                        
                        if isnumeric(val) && prod(size(val)) > 1 % if this is an image
                            
                            subFolder = num2str(i);
                            fileName = [fieldName, '.', ext];
                            fullFolderPath = fullfile(folderPath, subFolder);
                            fullFilePath = fullfile(fullFolderPath, fileName);
                            mkdir(fullFolderPath);
                            imwrite(val, fullFilePath, ext, 'Compression', 'none');
                            
                            newVal = fullFilePath;
                        else
                            
                            newVal = val;
                        end
                        
                        savedData(i).(fieldName) = newVal;
                    end
                    
                end
            end
            
            csvPath = fullfile(folderPath, csvFile);
            obj.writeStructToCsv(savedData, csvPath);
            
        end
        
        function writeStructToCsv(obj, savedData, csvPath) % used in writeDate()
            T = struct2table(savedData);
            writetable(T, csvPath, 'Delimiter', ',');
        end
        
        function someData = getSomeData(obj, params)

          % Returns all the data entries that have values as given in the second argument
          % e.g.: all entries from well A1, time 1,2,3, etc.
          % params - {varName1, [varVal1 varVal2, varVal3], varName2, [� ], � }
          
          if (exist('params', 'var') && iscell(params))
              
              foundInds = [];
              
              for ind = 1 : numel(obj.allData)
                  
                  notFound = false;
                  for i = 1 : numel(params)
                      % odd i's are variable names, even i's are lists of
                      % possible values
                      if (mod(i, 2))
                          varName = params{i};
                      else
                          valList = params{i};
                          varVal = obj.allData(ind).(varName);
                          if (isnumeric(varVal) && isnumeric(valList))
                              if (~any(valList == varVal))
                                  notFound = true;
                              end
                          elseif (ischar(varVal) && ischar(valList))
                              if (~strcmp(valList, varVal))
                                  notFound = true;
                              end
                          end
                          
                      end
                  end
                  if (~notFound)
                      foundInds = [foundInds, ind];
                  end
              
              end
              
              someData = obj.allData(foundInds);      
          end
        end
        
        
    end
end

