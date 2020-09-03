function result = cellSurvivalVsDropletSize(entities, parameters)

    props = parseParams(parameters);
        
    % get param names
    fns = fieldnames(entities(1).dataParameters);
    
    % TODO: struct creation is messy...
    for ei = numel(entities):-1:1
        res(ei) = entities(ei).dataParameters;
    end 
    
    [res.val] = deal([]);
    
    for ei = numel(entities):-1:1
        res(ei).val = interpolateNN(entities(ei), props);
    end
    
    %nd = createNDResultTable(res, 'val', fns);
    nd = NDResultTable(res, 'val', fns);
    
    
    if (~isempty(props.colateBy))
        dim = find(strcmp(nd.names,props.colateBy));
        vals = nd.vals{dim};
        nd = nd.colateTable(nd,(props.colateBy));

    end

    for ti = 1:numel(nd.T)
       nd.T{ti}{1} = {cell2mat(nd.T{ti})} 
    end

    
    result = nd;

    % TODO: and for removing dimension of size 1 (? but what will happen to a
    % single data entry ?)
    
end

function res = interpolateNN(entityStruct, props)
    
obsDistancesSorted = sort(entityStruct.expDistances);

obsQuantityAtDistance = find(obsDistancesSorted>props.colateValue,1);
obsQuantityTotal = numel(obsDistancesSorted);

rndQuantityAtDistance = [];
rndTotalCount = [];
for i = 1:numel(entityStruct.allRndDistances)
    rndDistancesSorted = sort(entityStruct.allRndDistances{i});
    rndQuantityAtDistance(i) = find(rndDistancesSorted>props.colateValue,1);
    rndQuantityTotal(i) = numel(rndDistancesSorted);
end

res.obsQuantityAtDistance = obsQuantityAtDistance;
res.obsQuantityTotal = obsQuantityTotal;
res.rndQuantityAtDistance = rndQuantityAtDistance;
res.rndQuantityTotal = rndQuantityTotal;
res.time = entityStruct.dataParameters.(props.colateBy);

end

function props = parseParams(v)
% default:
props = struct(...
    'colateBy','time', ...
    'colateValue','5' ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'colateBy'))
        props.colateBy = v{i+1};
    elseif (strcmp(v{i}, 'colateValue'))
        props.colateValue = v{i+1};
    end
end

end
