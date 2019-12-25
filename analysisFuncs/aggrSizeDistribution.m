function result = aggrSizeDistribution(entities, parameters)

props = parseParams(parameters);

% get param names
fns = fieldnames(entities(1).dataParameters);

% TODO: struct creation is messy...
for ei = numel(entities):-1:1
    res(ei) = entities(ei).dataParameters;
end

[res.val] = deal([]);

for ei = numel(entities):-1:1
    pA = (entities(ei).dataParameters.pixelSize)^2;
    
    if (isempty(entities(ei).(props.aggrArea)))
        res(ei).val = 0;
        res(ei).FoVArea = 0;
    else
        res(ei).val = entities(ei).(props.aggrArea)*pA;
        res(ei).FoVArea = numel(entities(ei).seg)*pA;
    end
end

%nd = createNDResultTable(res, 'val', fns);
nd = NDResultTable(res, 'val', fns);
nd2 = NDResultTable(res, 'FoVArea', fns);

% TODO: use some func for this - simple concatanation...
for ti = 1:numel(nd.T)
    if (~isempty(nd.T{ti}))
        vv = nd.T{ti}{1};
        for ri = 2:numel(nd.T{ti})
            vv = [vv; nd.T{ti}{ri}];
        end
        nd.T{ti} = cell(0);
        nd.T{ti}{1} = vv;
    end
end

bins = [0,logspace(props.bins_min,props.bins_max+props.bins_step,2+(props.bins_max - props.bins_min)/props.bins_step)];
% TODO: and for this a simple cellfunc would do...
for ti = 1:numel(nd.T)
    if (~isempty(nd.T{ti}))
        areas = nd.T{ti}{1};
        
        FovArea_mm2 = nd2.T{ti}{1}/1e6;
        
        totAreaInBins = [];
        [Ni,~,binidx] = histcounts(areas,bins);
        
        Ni = Ni / FovArea_mm2;
        
        if (props.accumArea)
            for bi = 1:numel(Ni)
                totAreaInBins(bi) = sum(areas(binidx==bi));
            end
            relAreaInBins = totAreaInBins / sum(totAreaInBins);
            
            
            vva = struct('X', bins(1:end-1), 'Y', relAreaInBins);
        else
            vva = struct('X', bins(1:end-1), 'Y', Ni);
        end
        nd.T{ti}{1} = vva;
    end

    
    result = nd;
    
    % ndDataParams = getDataParams(entities, fns)
    % results = uniteNDtables(nd, ndDataParmas)


end

% TODO: and for removing dimension of size 1 (? but what will happen to a
% single data entry ?)


end

function props = parseParams(v)
% default:
props = struct(...
    'accumArea', 0, ...
'aggrArea','area', ...
    'bins_min',-0.5, ...
    'bins_max',4, ...
    'bins_step', 0.1 ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'aggrArea'))
        props.aggrArea = v{i+1};
    elseif (strcmp(v{i}, 'accumArea'))
        props.accumArea = v{i+1};
    elseif (strcmp(v{i}, 'bins_min'))
        props.bins_min = v{i+1};
    elseif (strcmp(v{i}, 'bins_max'))
        props.bins_max = v{i+1};
    elseif (strcmp(v{i}, 'bins_step'))
        props.bins_step = v{i+1};
    end
end

end


