function result = aggrSurvivalVsAggrSizeVsDropletSize(entities, parameters)

    props = parseParams(parameters);
        
    % get param names
    fns = fieldnames(entities(1).dataParameters);
    
    % TODO: struct creation is messy...
    for ei = numel(entities):-1:1
        res(ei) = entities(ei).dataParameters;
    end 
    
    [res.val] = deal([]);
    
    for ei = numel(entities):-1:1
        res(ei).val = getAggrSurvivalVsAggrSizeVsDropletSize(entities(ei), props);
    end
    
    %nd = createNDResultTable(res, 'val', fns);
    nd = NDResultTable(res, 'val', fns);
    
    % TODO: use some func for this - simple concatanation...
    for ti = 1:numel(nd.T)
        if (~isempty(nd.T{ti}))
            vv = nd.T{ti}{1};
            for ri = 2:numel(nd.T{ti})
               vv.aggrArea = [vv.aggrArea; nd.T{ti}{ri}.aggrArea];
               vv.dropletArea = [vv.dropletArea; nd.T{ti}{ri}.dropletArea];
               vv.survival = [vv.survival; nd.T{ti}{ri}.survival];
            end
            nd.T{ti} = cell(0);
            nd.T{ti}{1} = vv;
        end
    end

    % TODO: and for this a simple cellfunc would do...
	for ti = 1:numel(nd.T)
        if (~isempty(nd.T{ti}))
            vv = nd.T{ti}{1};
            ratioMat = doBinning(vv.dropletArea, vv.aggrArea, vv.survival, props.aggrAreaBins, props.dropletAreaBins);
            vv.ratioMat = ratioMat;
            nd.T{ti}{1} = vv;
        end
    end
    
    result = nd;

    % TODO: and for removing dimension of size 1 (? but what will happen to a
    % single data entry ?)
    
end

function res = doBinning(areaD, areaA, ratio, aggrBins, dropBins)
    
    [N,Xedges,Yedges,binX,binY] = histcounts2(areaD, areaA, dropBins, aggrBins);

    ratioMatCell = cell(size(N));
    countMat = zeros(size(N));

    for ii = 1:numel(binX)
        if binX(ii) && binY(ii)
            ratioMatCell{binX(ii),binY(ii)} = [ratioMatCell{binX(ii),binY(ii)}, ratio(ii)]; 
        end
    end
    
    ratioMat = zeros(size(N));
    
    ratioMatErr = zeros(size(N));
    for ri = 1: numel(ratioMat) 
        ratioMat(ri) = mean(ratioMatCell{ri});
        ratioMatErr(ri) = std(ratioMatCell{ri})/sqrt(numel(ratioMatCell{ri}));
        if numel(ratioMatCell{ri}) <=1
            ratioMat(ri) = nan;
            ratioMatErr(ri) = nan;
        end
    end
    
    res = ratioMat;

end

function res = getAggrSurvivalVsAggrSizeVsDropletSize(entityStruct, props)

    pA = (entityStruct.dataParameters.pixelSize)^2;
    dropletArea = entityStruct.(props.dropletArea); 
    aggrArea = entityStruct.(props.aggrArea);
    aggrSurvival = entityStruct.(props.aggrSurvival);
    
    totalDropletArea = zeros(size(dropletArea));
    for i = 1:numel(totalDropletArea)
        totalDropletArea(i) = sum((dropletArea{i}));
    end
    
    res.aggrArea = aggrArea * pA;
    res.dropletArea = totalDropletArea * pA;
    res.survival = aggrSurvival;
    
end

function props = parseParams(v)
% default:
props = struct(...
    'aggrArea','area', ...
    'aggrSurvival','cLDRatio', ...
    'dropletArea','dArea', ...
    'dropletAreaBins',[1 10^2 10^3 10^4 10^5 inf], ...
    'aggrAreaBins',[1 10^2 10^3 10^4 10^5 inf] ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'aggrArea'))
        props.aggrArea = v{i+1};
    elseif (strcmp(v{i}, 'aggrSurvival'))
        props.aggrSurvival = v{i+1};
    elseif (strcmp(v{i}, 'dropletArea'))
        props.dropletArea = v{i+1};
    elseif (strcmp(v{i}, 'dropletAreaBins'))
        props.dropletAreaBins = v{i+1};
    elseif (strcmp(v{i}, 'aggrAreaBins'))
        props.aggrAreaBins = v{i+1};
    end
end

end
