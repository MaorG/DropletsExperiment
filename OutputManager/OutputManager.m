classdef OutputManager < dynamicprops
    
    properties
        dm
        enm
        am
    end
    
    methods
        function obj = OutputManager(dm, enm, am)
            obj.am = am;
            obj.dm = dm;
            obj.enm = enm;
        end
        
        function doOutput(obj, outputConfig)
            disp(outputConfig)
            for i = 1:numel(outputConfig)
                disp(outputConfig(i));
                obj.doOutputRow(outputConfig(i))
            end
        end
        
        function doOutputRow(obj, outputConfigRow)
            
            if strcmpi('analysis', outputConfigRow.stage)
                doOutputRowAnalysis(obj, outputConfigRow)
            else
                doOutputRowData(obj, outputConfigRow)
            end
        end
        
        function doOutputRowData(obj, outputConfigRow)
            parameters = outputConfigRow.parameters;
            %src = obj.am.(outputConfigRow.srcName);
            funcName = outputConfigRow.funcName;
            filter = outputConfigRow.filter;
            
            fData = obj.dm.filterData(filter);
            
            for i = 1:numel(fData)
                entry = fData(i);
                str = obj.getTitle(entry, filter(1:2:end));
                figure('Name', str);
                eval([funcName '(entry, parameters)'])
                title(str);
            end
        end
        
        function str = getTitle(obj, entry, filterNames)
            % TODO: make static and paramatrize "params" field
            str = "";
            fns = fieldnames(entry.parameters);
            for fi = 1:numel(fns)
                %if (sum(contains(filterNames, fns(fi))) > 0)
                    if isnumeric(entry.parameters.(fns{fi}))
                        str = strcat(str, " | ", fns{fi}, ': ', num2str(entry.parameters.(fns{fi})));
                    else
                        str = strcat(str, " | ", fns{fi}, ': ', entry.parameters.(fns{fi}));
                    end
                %end
            end
            
        end
        
        
        function doOutputRowAnalysis(obj, outputConfigRow)
            
            parameters = outputConfigRow.parameters;
            src = obj.am.(outputConfigRow.srcName);
            filter = outputConfigRow.filter;
            
            if isempty(filter)
                tableUI(src, str2func(outputConfigRow.funcName),[], parameters)
            else
                entries = src.getEntriesByFilter(filter);
                for ei = 1:numel(entries)
                    str = obj.getTitle(entries(ei), filter(1:2:end));
                    figure('Name', str);
                    entry = entries(ei).data;
                    eval([outputConfigRow.funcName, '(entry, parameters)']);
                    title(strcat(outputConfigRow.srcName, ' ', str));
                end
            end
            
            %filteredRT = src.filter(filter);
            
            
            
            
            %obj.(resName) = eval([outputConfigRow.funcName, '(src, parameters)']);
            
            % TODO:  this is too simplistic and lazy... e.g. the filtering
            % can and should take place before actually calling the output
            % func
            % perhaps the manager can extract the data from the src NDTable
            % and pass is to the func
            % -> so now 'filter' is a separate column. other parameters can
            % be passed into the display func
            
        end
        
    end
end

