function result = michael_func(entities, parameters)

    props = parseParams(parameters);
        
    % get param names
    fns = fieldnames(entities(1).dataParameters);
    
    % TODO: struct creation is messy...
    for ei = numel(entities):-1:1
        res(ei) = entities(ei).dataParameters;
    end 
    
    [res.val] = deal([]);
    
    for ei = numel(entities):-1:1
        res(ei).val = getCellSurvivalVsDropletSize(entities(ei), props);
    end
    
    %nd = createNDResultTable(res, 'val', fns);
    nd = NDResultTable(res, 'val', fns);
    
    % TODO: use some func for this
    % uniting similar datas
    for ti = 1:numel(nd.T)
        if (~isempty(nd.T{ti}))
            vv = nd.T{ti}{1};
            for ri = 2:numel(nd.T{ti})
               vv.area = [vv.area; nd.T{ti}{ri}.area];
               vv.pop = [vv.pop; nd.T{ti}{ri}.pop];
            end
            vv.area = vv.area;
            nd.T{ti} = cell(0);
            nd.T{ti}{1} = vv;
        end
    end

    % TODO: and for this
	for ti = 1:numel(nd.T)
        if (~isempty(nd.T{ti}))
            % actual work
            vv = nd.T{ti}{1};
            area = vv.area;
            pop = vv.pop;
            [areaSorted, areaOrder] = sort(area);
            popSorted = pop(areaOrder);
            popFracSorted = cumsum(popSorted,'reverse') ./ sum(popSorted);
            
            vv.X = areaSorted;
            vv.Y = popFracSorted;
            vv.props = props;
            
            nd.T{ti}{1} = vv;
        end
    end
    
    result = nd;

    % TODO: and for removing dimension of size 1 (? but what will happen to a
    % single data entry ?)
    
end

function res = getCellSurvivalVsDropletSize(entityStruct, props)

pA = (entityStruct.dataParameters.pixelSize)^2;

dropletArea = entityStruct.(props.dropletArea) * pA;
cellArea = entityStruct.(props.cellArea);
sumCellArea = cellfun(@(x) sum(x), cellArea);
sumCellArea = sumCellArea * pA;

minAreaInds = dropletArea > 31;
dropletArea = dropletArea(minAreaInds);
sumCellArea = sumCellArea(minAreaInds);




res.area = dropletArea;
res.pop = sumCellArea;
    
end

function props = parseParams(v)
% default:
props = struct(...
    'cellArea','cArea', ...
    'cellSurvival','cLDRatio', ...
    'dropletArea','area', ...
    'dropletAreaBins',[1 10^2 10^3 10^4 10^5 inf] ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'cellArea'))
        props.cellArea = v{i+1};
    elseif (strcmp(v{i}, 'cellSurvival'))
        props.cellSurvival = v{i+1};
    elseif (strcmp(v{i}, 'dropletArea'))
        props.dropletArea = v{i+1};
    elseif (strcmp(v{i}, 'dropletAreaBins'))
        props.dropletAreaBins = v{i+1};
    end
end

end
