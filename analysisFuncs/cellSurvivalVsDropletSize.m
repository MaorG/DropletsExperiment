function result = cellSurvivalVsDropletSize(entities, parameters)

    props = parseParams(parameters);
        
    % get param names
    fns = fieldnames(entities(1).dataParams);
    
    % TODO: struct creation is messy...
    for ei = numel(entities):-1:1
        res(ei) = entities(ei).dataParams;
    end 
    
    [res.val] = deal([]);
    
    for ei = numel(entities):-1:1
        res(ei).val = getCellSurvivalVsDropletSize(entities(ei), props);
    end
    
    %nd = createNDResultTable(res, 'val', fns);
    nd = NDResultTable(res, 'val', fns);
    
    % TODO: use some func for this
    for ti = 1:numel(nd.T)
        if (~isempty(nd.T{ti}))
            vv = nd.T{ti}{1};
            for ri = 2:numel(nd.T{ti})
               vv.area = [vv.area; nd.T{ti}{ri}.area];
               vv.survival = [vv.survival; nd.T{ti}{ri}.survival];
            end
            vv.area = vv.area;
            nd.T{ti} = cell(0);
            nd.T{ti}{1} = vv;
        end
    end

    % TODO: and for this
	for ti = 1:numel(nd.T)
        if (~isempty(nd.T{ti}))
            vv = nd.T{ti}{1};
            area = vv.area * 1;
            survival = vv.survival;
            [N,~,areabin] = histcounts(area,props.dropletAreaBins);
            for i = 1:numel(N)
                X(i) = props.dropletAreaBins(i);
                Ylist = survival(areabin == i);
                Y(i) = (nanmean((Ylist)));
                Yste(i) = nanstd(Ylist) ./ sqrt(numel(Ylist));
            end
            
            vv.X = X;
            vv.Y = Y;
            vv.Yste = Yste;
            nd.T{ti}{1} = vv;
        end
    end
    
    result = nd;

    % TODO: and for removing dimension of size 1 (? but what will happen to a
    % single data entry ?)
    
end

function res = getCellSurvivalVsDropletSize(entityStruct, props)

    pA = (entityStruct.dataParams.pixelSize)^2;
    dropletArea = entityStruct.(props.dropletArea) * pA;
    cellArea = entityStruct.(props.cellArea); % no need to multiply by pA since relative
    cellSurvival = entityStruct.(props.cellSurvival);
    
    totalSurvival = zeros(size(dropletArea));
    for i = 1:numel(totalSurvival)
        totalSurvival(i) = sum((cellArea{i}.*cellSurvival{i})./sum(cellArea{i}));
    end
    
    res.area = dropletArea;
    res.survival = totalSurvival;
    
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
