classdef OutputManager < dynamicprops
    
    properties
        dm
        enm
        am
        defaultOutputParams
        postOpsProps
        postOps
    end
    
    methods
        function obj = OutputManager(dm, enm, am)
            obj.am = am;
            obj.dm = dm;
            obj.enm = enm;
            obj.defaultOutputParams = [];
            obj.postOpsProps = {'legend', 'title'};
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
            elseif strcmpi('data', outputConfigRow.stage)
                doOutputRowData(obj, outputConfigRow)
            elseif strcmpi('defaultParams', outputConfigRow.stage)
                addDefaultParams(obj, {{{outputConfigRow.funcName} {outputConfigRow.parameters}}});
            end
            
            % TODO: add 'data' stage, for defaultParameters
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
        
        function addDefaultParams(obj, params)
            obj.defaultOutputParams = [obj.defaultOutputParams, params];
            % each params added should be one cell that contains two cells - first is which funcs it applies to (empty for all),
            % second is the actual parameters; thus different parameters can be added to different functions
        end
        
        function doOutputRowAnalysis(obj, outputConfigRow)

            % TODO: merge default and user parameters

            parameters = outputConfigRow.parameters;
%             sp = struct()
%             for i = 1:2:numel(parameters)
%                 sp.(parameters{i}) = parameters{i+1}
%             end
%             
%             spd = struct()
%             for i = 1:2:numel(obj.defaultOutputParams{1}{2}{1})
%                 spd.(obj.defaultOutputParams{1}{2}{1}{i}) = obj.defaultOutputParams{1}{2}{1}{i}
%             end
%             
%             spu = spd;
%             for fn = fieldnames(sp)
%                 spu.(fn{1}) = sp.(fn{1});
%             end
            
            
            for i = 1 : numel(obj.defaultOutputParams)
                defParams = obj.defaultOutputParams{i};
                funcs = defParams{1}{1};
                params = defParams{2}{1};
                if (isempty(funcs) || any(strcmp(funcs, outputConfigRow.funcName)))
                    parameters = mergeParams(params, parameters);
                end
            end
            
            src = obj.am.(outputConfigRow.srcName);
            filter = [];
            dimensionToHold = [];

            if isfield(outputConfigRow, 'filter') && ~isempty(outputConfigRow.filter) 
                filter = outputConfigRow.filter;
                src = src.filter(src, outputConfigRow.filter);
            end
            
            if isfield(outputConfigRow, 'hold') && ~isempty(outputConfigRow.hold)
                for singleHold = outputConfigRow.hold
                    dimensionToHold = singleHold;
                    % TODO: colate table sensitive to order ?!?!?!
                    % TODO: take care of a "singleton" dimension
                    % (especially at the last position on dimOrder)
               
                    src = src.colateTable(src, dimensionToHold);
                end
            end
            

            
            if isempty(filter) && isempty(dimensionToHold)
                tableUI(src, str2func(outputConfigRow.funcName),[], parameters)
            else
                %entryGroups = src.getEntriesByFilter(filter);
                entryGroups = src.getEntriesByFilter({});
                for gi = 1:numel(entryGroups)
                    
                    if ~isempty(entryGroups{gi})
                        % TODO: !!!
                        % hmmm title depends on filter, can now be based on
                        % src.vals(src.Tidx) or something like that
                        str = obj.getTitle(entryGroups{gi}(1), filter(1:2:end));
                        h = figure('Name', str);
                        hold on;
                        h = [];
                        titl = [];
                        obj.remPostOps();
                        for ei = 1:numel(entryGroups{gi})
                            entry = entryGroups{gi}(ei).data;
                            
                            try
                                %if (~isempty(entry))
                                    h = eval([outputConfigRow.funcName, '(entry, parameters)']);
                                    obj.addPostOps(h);
                                %end
                            
                            catch ME
                               %if (~strcmp(ME.identifier, 'MATLAB:unassignedOutputs'))
                               if (strcmp(ME.identifier, 'MATLAB:TooManyOutputs'))
                                   eval([outputConfigRow.funcName, '(entry, parameters)']);
                               else
                                   rethrow(ME);
                               end
                            end
                            
                        end
                        
                        if (isfield(obj.postOps, 'title') && ~isempty(obj.postOps.title)) 
                            title(obj.postOps.title);
                        else
                            title(strcat(outputConfigRow.srcName, ' ', str));
                        end
                        
                        if (isfield(obj.postOps, 'legend') && ~isempty(obj.postOps.legend))
                            legend(obj.postOps.legend,'Location', 'NorthEast');
                        end
                        
                        if (isfield(outputConfigRow, 'figPostOps'))
                            ops = outputConfigRow.figPostOps;
                            for o = 1 : numel(ops)
                                eval(ops{o});
                            end
                        end
                        
                    end
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
        
        function addPostOps(obj, h)
            for p = obj.postOpsProps
                if (isfield(h, p{1}))
                    obj.postOps.(p{1}) = [obj.postOps.(p{1}), h.(p{1})];
                end
            end
        end
        
        function remPostOps(obj)
            for p = obj.postOpsProps
                obj.postOps.(p{1}) = [];
            end
        end
        
    end
end

