classdef NDResultTable
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
        
        function entries = getEntriesByFilter(RT, filterProps)
            
            filterPairs = reshape(filterProps,2,numel(filterProps)/2)';
            if(numel(filterProps) == 0)
                dimIdxs = [];
            else
                dimIdxs = find(strcmp(RT.names, {filterPairs{:,1}}'));
            end
            
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
                    entry = {struct('parameters', sp, 'data', RT.T{ti})};
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
        
        function RTout = colateTable(RT, dimToColate)
            
            dimIndex = cellfun(@(x) strcmp(x, dimToColate), RT.names);
            
            [~,newDimOrder] = sort(dimIndex);
            
            newDims = RT.dims(newDimOrder(1:end-1));
            newNames = RT.names(newDimOrder(1:end-1));
            newVals = RT.vals(newDimOrder(1:end-1));
            newStrvals = RT.strvals(newDimOrder(1:end-1));
            
            permutedDims = RT.dims(newDimOrder);
            permutedT = permute(RT.T, newDimOrder);
            
            newT = cell(newDims);
            newTidx = cell(newDims);
            
            N = prod(newDims);
            
            
            for i = 1:N
                newSub = cell(size(newDims));
                [newSub{:}] = ind2sub(newDims, i);
                newTidx{i} = cat(1,newSub{:});
                for j = 1:numel(RT.vals{dimIndex})
                    permutedSub = [newSub, j];
                    args = cell([numel( RT.dims) + 1, 1]);
                    args{1} = permutedDims;
                    for k = 1:numel(permutedSub)
                        args(k+1) = permutedSub(k);
                    end
                    
                    indn = sub2ind(args{:})
                    ~isempty(cell2mat(permutedT{indn}))
                    
                    if ~isempty(permutedT{indn})
                        newT{i} = [newT{i}, {permutedT{indn}{1}}]
                    end
                    %                     if (~isempty(cell2mat(permutedT{indn})) & ~isnan(permutedT{indn}{1}))
                    %                         Y(j) = cell2mat(permutedT{indn});
                    %                     else
                    %
                    %                     end
                end
                
            end
            
            RTout = RT;
            RTout.dims = newDims;
            RTout.names = newNames;
            RTout.vals = newVals;
            RTout.strvals = newStrvals;
            RTout.Tidx = newTidx;
            RTout.T = newT;
            
        end
        
        
        function fRT = filter(RT, filterProps)
            
            fRT = RT;
            
            % get filter in nicer form
            filterPairs = reshape(filterProps,2,numel(filterProps)/2)';
            
            for fi = 1:size(filterPairs,1)
                % for each filtered field
                % remove (N-1) dimension slice if they are not included
                
                %@(fRT) (find(strcmp('mode', fRT.names)))
                
                fRT = RT.keepSlicesByNames(fRT, filterPairs{fi,1}, filterPairs{fi,2});
            end
        end
        
        function fRT = keepSlicesByNames(RT, dimensionName, sliceVals)
            dimensionIdx = find(strcmp(dimensionName, RT.names));

            
            if (~iscell(sliceVals))
                sliceVals = {sliceVals};
            end

            sliceIdxs = zeros(size(RT.vals{dimensionIdx}));
            if isnumeric(sliceVals)
                for i = 1:numel(sliceVals)
                    sliceIdxs = sliceIdxs | ismember(RT.vals{dimensionIdx}, sliceVals(i));
                end
            else
                for i = 1:numel(sliceVals)
                    sliceIdxs = sliceIdxs | strcmp(RT.vals{dimensionIdx}, sliceVals{i});
                end

            end
            %fRT = keepSlices(RT, dimensionIdx, sliceIdxs);
            fRT = RT.keepSlices(RT, dimensionName, sliceIdxs);
        end
        
        function fRT = keepSlices(RT, dimensionName, sliceIdxs)
            
            dimIndex = cellfun(@(x) strcmp(x, dimensionName), RT.names);
            
            %[~,newDimOrder] = sort(dimIndex);
            
            newDims = RT.dims;
            newDims(find(dimIndex)) = sum(sliceIdxs);
            newNames = RT.names;
            newVals = RT.vals;
            newVals{find(dimIndex)} = newVals{find(dimIndex)}(sliceIdxs);
            newStrvals = RT.strvals;
            newStrvals{find(dimIndex)} = RT.strvals{find(dimIndex)}(sliceIdxs);
            
            [~,permuteDimToEnd] = sort(dimIndex);
            permuteDimToOri(permuteDimToEnd) = 1:length(permuteDimToEnd);
            permutedDims = newDims(permuteDimToEnd);
            
            indicesToKeep = repmat(sliceIdxs(:)',prod(permutedDims(1:end-1)),1);
            indicesToKeep = indicesToKeep(:);
            
            permutedT = permute(RT.T, permuteDimToEnd);
            %permutedTidx = permute(RT.Tidx, permuteDimToEnd);
            
            filteredT = permutedT(indicesToKeep);
            %filteredTidx = permutedTidx(indicesToKeep);
            
            permutedT = reshape(filteredT,permutedDims);
            %permutedTidx = reshape(filteredTidx,permutedDims)
            
            newT = permute(permutedT,permuteDimToOri);
            %newTidx = permute(permutedTidx,permuteDimToOri)
            
            
            % getting the content of Tidx "empirically"
            newTidx = cell(newDims);
            N = prod(newDims);
            for i = 1:N
                newSub = cell(size(newDims));
                [newSub{:}] = ind2sub(newDims, i);
                newTidx{i} = cat(1,newSub{:});
            end
            
            fRT = RT;
            fRT.dims = newDims;
            fRT.names = newNames;
            fRT.vals = newVals;
            fRT.strvals = newStrvals;
            fRT.Tidx = newTidx;
            fRT.T = newT;
            
        end
        
        
        function [index] = flattenField(allData, fieldName, newFieldName, vararg)
            index = cumprod([1 tSize(1:end-1)]) * (indices(:) - [0; ones(numel(indices)-1, 1)]);
        end
    end
    
end