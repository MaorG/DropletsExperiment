classdef NDResultTable < handle
    properties
        title;
        dims;
        names;
        vals;
        strvals;
        T;
        Tidx;
    end
    
    methods
        
        function [resultTable] = NDResultTable (allData, fieldName, varargin)
            
            % get parameters names and values
            
            nVars = length(varargin);
            pNames = [];
            
            if(ischar(varargin{1}))
                nVars = length(varargin);
                for i = 1:nVars
                    pNames = [pNames; varargin(i)];
                end
            else
                nVars = length(varargin{1});
                for i = 1:nVars
                    pNames = [pNames; varargin{1}(i)];
                end
            end
            
            pVals = cell(nVars,1);
            
            for i = 1:nVars
                pVals{i} = extractfield(allData, pNames{i});
                pVals{i} = sort(unique(pVals{i}));
            end
            
            dims = arrayfun(@(i) numel(pVals{i}), 1:numel(pVals));
            
            T = cell(dims);
            T = cellfun(@(t) cell(0), T, 'UniformOutput', false);
            
            Tidx = cell(dims);
            Tidx = cellfun(@(t) cell(0), T, 'UniformOutput', false);
            
            resultTable.title = fieldName;
            resultTable.dims = dims;
            resultTable.names = pNames;
            resultTable.vals = pVals;
            resultTable.strvals = cell(size(pVals));
            for ii = 1:numel(pVals)
                strs = cell(0);
                for jj = 1:numel(pVals{ii})
                    if isnumeric(pVals{ii}(jj))
                        str = num2str(pVals{ii}(jj));
                    else
                        str = pVals{ii}(jj);
                    end
                    strs = [strs str];
                end
                resultTable.strvals{ii} = strs;
            end
            resultTable.T = T;
            resultTable.Tidx = Tidx;
            
            for i = 1:numel(allData)
                resultTable = resultTable.add2T(resultTable, fieldName, allData(i));
            end
            
           
        end
        
        function fRT = filter(RT, filterProps)

            fRT = RT;

            % get filter in nicer form 
            filterPairs = reshape(filterProps,2,2)';

            for fi = 1:size(filterPairs,1)
            % for each filtered field
                % remove (N-1) dimension slice if they are not included
                
                %@(fRT) (find(strcmp('mode', fRT.names)))
                
                fRT = keepSlicesByNames(fRT, filterPairs{fi,1}, filterPairs{fi,2});
            end
        end       
        
        function RT = keepSlicesByNames(RT, dimensionName, sliceVals)
            dimensionIdx = find(strcmp(dimensionName, RT.names));
            if isnumeric(sliceVals)
                sliceIdxs = ismember(RT.vals{dimensionIdx}, sliceVals);
            else
                sliceIdxs = contains(RT.vals{dimensionIdx}, sliceVals);
            end
            RT = removeSlices(RT, dimensionIdx, sliceIdxs);
        end
        
        function RT = keepSlices(RT, dimensionIdx, sliceIdxs)
%             RT.dims(dimensionIdx) = RT.dims(dimensionIdx) - 1;
%             sliceIdx2keep;
%             vals = RT.vals(dimensionIdx);
%             vals{1}{2}=[];
        end
        
        
        function entries = getEntriesByFilter(RT, filterProps)
            filterPairs = reshape(filterProps,2,numel(filterProps)/2)';
            dimIdxs = find(contains(RT.names, {filterPairs{:,1}}'));
            
            tindices = [];
            entries = [];
            for ti = 1:numel(RT.Tidx)
                if isempty(RT.Tidx{ti})
                    continue
                end
                m_vals = {};
                cindices = RT.Tidx{ti};
                for i=1:numel(RT.Tidx{ti})
                    m_vals{i} = RT.vals{i}(cindices(i));
                end
                sp = struct;
                for i = 1:numel(RT.names)
                    sp.(RT.names{i}) = m_vals{i};
                end
                
                toKeep = 1;
                for fi = 1:size(filterPairs,1)
                    if isfield(sp, filterPairs{fi,1})
                        if isnumeric(sp.(filterPairs{fi,1}))
                            if sum(sp.(filterPairs{fi,1}) == cell2mat(filterPairs{fi,2})) == 0
                                toKeep = 0;
                            end
                        else
                            if sum(strcmp(sp.(filterPairs{fi,1}), filterPairs{fi,2})) == 0
                                toKeep = 0;
                            end
                        end
                    end
                end
                
                if (toKeep)
                    tindices = [tindices, ti];
                    entry = struct('parameters', sp, 'data', RT.T{ti});
                    entries = [entries, entry];
                end
            end

        end
    end
    
    
    methods (Static)
        function [index] = computeIndex(tSize, indices)
            index = cumprod([1 tSize(1:end-1)]) * (indices(:) - [0; ones(numel(indices)-1, 1)]);
        end
        
        function [resultTable] = add2T(resultTable, fieldName, data)
            
            indices = zeros(size(resultTable.names));
            
            for i = 1:numel(indices)
                if (isnumeric(data.(resultTable.names{i})))
                    indices(i) = find(resultTable.vals{i} == data.(resultTable.names{i}));
                else
                    indices(i) = find(strcmpi(data.(resultTable.names{i}), resultTable.vals{i}));
                end
            end
            
            index = resultTable.computeIndex(resultTable.dims, indices);
            
            resultTable.T{index} = [resultTable.T{index}; data.(fieldName)];
            resultTable.Tidx{index} = indices;
            %resultTable.T{index} = [data.(fieldName)];
            
        end
        
        function [index] = flattenField(allData, fieldName, newFieldName, vararg)
            index = cumprod([1 tSize(1:end-1)]) * (indices(:) - [0; ones(numel(indices)-1, 1)]);
        end
    end
    
end