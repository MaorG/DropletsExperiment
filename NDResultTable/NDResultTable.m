classdef NDResultTable < handle
    properties
        dims;
        names; 
        vals;
        T;
    end
    
    methods
        
        function [resultTable] = NDResultTable (allData, fieldName, varargin)
            
            % get parameters names and values
            
            nVars = length(varargin);
            pNames = [];
            for i = 1:nVars
                pNames = [pNames; varargin(i)];
            end
            
            pVals = cell(nVars,1);
            
            for i = 1:nVars
                pVals{i} = extractfield(allData, pNames{i});
                pVals{i} = sort(unique(pVals{i}));
            end
            
            pDims = arrayfun(@(i) numel(pVals{i}), 1:numel(pVals));
            
            Table = cell(pDims);
            Table = cellfun(@(t) cell(0), Table, 'UniformOutput', false);
            
            resultTable.dims = pDims;
            resultTable.names = pNames;
            resultTable.vals = pVals;
            
            
            
            resultTable.T = Table;
            
            for i = 1:numel(allData)
                i
                resultTable = add2T(resultTable, fieldName, allData(i));
            end
            
            % and now take the cell array at each cell in T and place along
            % the 'other' dimenstion
            
            % resultTable = flatten(resultTable);
            
        end
        
        function [resultTable] = flatten(resultTable, fieldName)

            lengths = cellfun(@(x) (numel(x(:))), resultTable.T);
            lengths = cellfun('length', resultTable.T);
            maxLength = max(reshape(lengths,1,[]));
            
            newDims = [resultTable.dims, maxLength];
            newNames = [resultTable.names; {fieldName}];
            newVals = [resultTable.vals; cell({1:maxLength})];
            
            A = cellfun(@(x) padcellarray(x(:), maxLength), resultTable.T, 'UniformOutput', false);
            newT = cell(newDims);
            
            N = prod(resultTable.dims);
            M = maxLength;
            
            for i = 1:N
                for j = 1:M
                    
                    out = cell(size(resultTable.dims));
                    [out{:}] = ind2sub(resultTable.dims, i);
                    
                    
                    subb = [cell2mat(out), j]';
                    args = cell([numel(newDims) + 1,1]);
                    args{1} = newDims;
                    for k = 1:numel(subb)
                        args{k+1} = subb(k);
                    end

                    indn = sub2ind(args{:});
                    newT{indn} = A{i}(j);
                end
            end

            resultTable.dims = newDims;
            resultTable.names = newNames;
            resultTable.vals = newVals;
            resultTable.T = newT;
            
        end
        
        function [resultTable] = add2T(resultTable, fieldName, data)
            
            indices = zeros(size(resultTable.names));
            
            for i = 1:numel(indices)
                indices(i) = find(resultTable.vals{i} == data.(resultTable.names{i}));
            end
            
            index = NDResultTable.computeIndex(resultTable.dims, indices);
            
            % for now, allow single entry per cell!
            resultTable.T{index} = [resultTable.T{index}; data.(fieldName)];
            % resultTable.T{index} = data.(fieldName);
            
        end
    end
    
    
    methods (Static)
        function [index] = computeIndex(tSize, indices)
            index = cumprod([1 tSize(1:end-1)]) * (indices(:) - [0; ones(numel(indices)-1, 1)]);
        end
        function [index] = flattenField(allData, fieldName, newFieldName, vararg)
            index = cumprod([1 tSize(1:end-1)]) * (indices(:) - [0; ones(numel(indices)-1, 1)]);
        end
    end
    
end