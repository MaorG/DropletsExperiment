function result = liveDeadBarsAnalyze(entities, parameters)

props = parseParams(parameters);

% get param names
fns = fieldnames(entities(1).dataParameters);

bins = [logspace(props.bins_min,props.bins_max+props.bins_step,2+(props.bins_max - props.bins_min)/props.bins_step) props.bins_append];

% TODO: struct creation is messy...
for ei = numel(entities):-1:1
    res(ei) = entities(ei).dataParameters;
end

[res.val] = deal([]);

for ei = numel(entities):-1:1
    res(ei).val = getLiveDeadBarsAnalyze(entities(ei), props);
end

%nd = createNDResultTable(res, 'val', fns);
nd = NDResultTable(res, 'val', fns);

% TODO: use some func for this
% uniting similar datas
for ti = 1:numel(nd.T)
    if (~isempty(nd.T{ti}))
        vv = nd.T{ti}{1};
        for ri = 2:numel(nd.T{ti})
            vv.dropletArea = [vv.dropletArea; nd.T{ti}{ri}.dropletArea];
            vv.cellArea = [vv.cellArea; nd.T{ti}{ri}.cellArea];
            vv.liveDeadRatio = [vv.liveDeadRatio; nd.T{ti}{ri}.liveDeadRatio];
            vv.totalPixels = vv.totalPixels + nd.T{ti}{ri}.totalPixels; % sum pixels for that group
        end
        nd.T{ti} = cell(0);
        nd.T{ti}{1} = vv;
    end
end


% TODO: and for this
for ti = 1:numel(nd.T)
    if (~isempty(nd.T{ti}))
        % actual work
        vv = nd.T{ti}{1};
        area = vv.dropletArea;
        cellArea = vv.cellArea;
        liveDeadRatio = vv.liveDeadRatio;
        
        live = liveDeadRatio .* cellArea;
        dead = (1-liveDeadRatio) .* cellArea;
        
        [N,~,areabin] = histcounts(area,bins);

        X = zeros(numel(N),1);
        Y = zeros(numel(N),1);
        Yste = zeros(numel(N),1);
        for i = 1:numel(N)
            X(i) = bins(i);
            YlistR =  (dead(areabin == i));
            YR(i) = sum(YlistR) / (vv.totalPixels * vv.pA * props.convertFactor);
            YlistG =  (live(areabin == i));
            YG(i) = sum(YlistG) / (vv.totalPixels * vv.pA * props.convertFactor);
        end
        
        YG./(YG+YR)

        vv.X = X;
        vv.YR = YR;
        vv.YG = YG;
        
        nd.T{ti}{1} = vv;
    end
end

result = nd;

% TODO: and for removing dimension of size 1 (? but what will happen to a
% single data entry ?)

end

function res = getLiveDeadBarsAnalyze(entityStruct, props)

pA = (entityStruct.dataParameters.pixelSize)^2;

dropletArea = entityStruct.(props.dropletArea);
viableCells = ~cellfun(@isempty, dropletArea); % to choose only cells that are inside droplets
dropletArea = dropletArea(viableCells);
dropletArea = cellfun(@(x) sum(x), dropletArea); % sum areas (cells might rarely be on the edge of more than one droplet)
dropletArea = dropletArea * pA; 

cellArea = entityStruct.(props.cellArea);
cellArea = cellArea(viableCells) * pA;

liveDeadRatio = entityStruct.(props.liveDeadRatio);
liveDeadRatio = liveDeadRatio(viableCells);

res.dropletArea = dropletArea;
res.cellArea = cellArea;
res.liveDeadRatio = liveDeadRatio;
res.totalPixels = numel(entityStruct.seg);
res.pA = pA;

end

function props = parseParams(v)
% default:
props = struct(...
    'cellArea','area', ...
    'liveDeadRatio','ldratio', ...
    'dropletArea','dArea', ...
    'dropletAreaBins',[1 10^2 10^3 10^4 10^5 inf], ...
    'bins_min', 1.25, ...
    'bins_max', 3.75, ...
    'bins_step', 0.5, ...
    'bins_append', inf, ...
    'convertFactor', 10^-6 ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'cellArea'))
        props.cellArea = v{i+1};
    elseif (strcmp(v{i}, 'liveDeadRatio'))
        props.cellSurvival = v{i+1};
    elseif (strcmp(v{i}, 'dropletArea'))
        props.dropletArea = v{i+1};
    elseif (strcmp(v{i}, 'dropletAreaBins'))
        props.dropletAreaBins = v{i+1};
    elseif (strcmp(v{i}, 'bins_min'))
        props.bins_min = v{i+1};
    elseif (strcmp(v{i}, 'bins_max'))
        props.bins_max = v{i+1};
    elseif (strcmp(v{i}, 'bins_step'))
        props.bins_step = v{i+1};
    elseif (strcmp(v{i}, 'bins_append'))
        props.bins_append = v{i+1};    
    elseif (strcmp(v{i}, 'convertFactor'))
        props.convertFactor = v{i+1};
        
    end
end

end
