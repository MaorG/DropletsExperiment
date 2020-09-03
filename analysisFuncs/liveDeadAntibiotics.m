function result = liveDeadAntibiotics(entities, parameters)

props = parseParams(parameters);

% get param names
fns = fieldnames(entities(1).dataParameters);

%bins = [logspace(props.bins_min,props.bins_max+props.bins_step,2+(props.bins_max - props.bins_min)/props.bins_step) props.bins_append];

% TODO: struct creation is messy...
for ei = numel(entities):-1:1
    res(ei) = entities(ei).dataParameters;
end

[res.val] = deal([]);

for ei = numel(entities):-1:1
    res(ei).val = getliveDeadAntibiotics(entities(ei), props);
end

%nd = createNDResultTable(res, 'val', fns);
nd = NDResultTable(res, 'val', fns);

% TODO: use some func for this
% uniting similar datas
for ti = 1:numel(nd.T)
    if (~isempty(nd.T{ti}))
        vv = nd.T{ti}{1};
        for ri = 2:numel(nd.T{ti})
            vv.totalLive = [vv.totalLive; nd.T{ti}{ri}.totalLive];
            vv.totalDead = [vv.totalDead; nd.T{ti}{ri}.totalDead];
            vv.totalArea = [vv.totalArea; nd.T{ti}{ri}.totalArea];
        end
        nd.T{ti} = cell(0);
        nd.T{ti}{1} = vv;
    end
end

nd = nd.colateTable(nd,'time'); %todo: paramterize

% TODO: and for this
for ti = 1:numel(nd.T)
    if (~isempty(nd.T{ti}))
        vvt = nd.T{ti}{1};
        vvt.X = nan(numel(nd.T{1}),1);
        vvt.Y = nan(numel(nd.T{1}),1);
        vvt.Ystd = nan(numel(nd.T{1}),1);
        
        for time_index = 1:numel(nd.T{1})
            vv = nd.T{ti}{time_index};
            live = vv.totalLive;
            dead = vv.totalDead;
            area = vv.totalArea;
            
            if strcmp(props.mode, 'ratio')
                
                vvt.Y(time_index) = mean(live./area);
                vvt.Ystd(time_index) = std(live./area);
                vvt.Yste(time_index) = vvt.Ystd(time_index)/sqrt(numel(live));
                vvt.X(time_index) = vv.time;
            elseif strcmp(props.mode, 'live')
                vvt.Y(time_index) = mean(live);
                vvt.Ystd(time_index) = std(live);
                vvt.Yste(time_index) = vvt.Ystd(time_index)/sqrt(numel(live));
                vvt.X(time_index) = vv.time;
            elseif strcmp(props.mode, 'liveCount')
                vvt.Y(time_index) = mean(live);
                vvt.Ystd(time_index) = std(live);
                vvt.Yste(time_index) = vvt.Ystd(time_index)/sqrt(numel(live));
                vvt.X(time_index) = vv.time;
            end
            
        end
        
        
        nd.T{ti}{1} = vvt;
    end
end

result = nd;

% TODO: and for removing dimension of size 1 (? but what will happen to a
% single data entry ?)

end

function res = getliveDeadAntibiotics(entityStruct, props)

pA = (entityStruct.dataParameters.pixelSize)^2;

if ~strcmp(props.mode, 'liveCount')
    
    totalCount = entityStruct.(props.cellArea);
    liveDeadArea = entityStruct.(props.liveDeadCount);
    liveCount = liveDeadArea(:,1);
    deadCount = liveDeadArea(:,2);
    
    deadRatioCutoff = props.deadRatioCutoff;
    
    testLive = @(total, dead, deadRatioCutoff) (total * deadRatioCutoff > dead);
    liveCells = arrayfun(testLive,totalCount,deadCount,repmat(deadRatioCutoff,size(totalCount)));
    
    res = struct;
    res.totalLive = sum(liveCells.*totalCount)*pA;
    res.totalDead = sum((~liveCells).*totalCount)*pA;
    res.totalArea = sum(totalCount)*pA;
    res.pA = pA;
    
    
    
    res.time = entityStruct.dataParameters.time; % todo: parametrize
else
    
    totalCount = entityStruct.(props.cellArea);
    liveDeadArea = entityStruct.(props.liveDeadCount);
    liveCount = liveDeadArea(:,1);
    deadCount = liveDeadArea(:,2);
    
    liveCount = numel(liveCount > 0);
    deadCount = numel(deadCount > 0);
    totalCount = numel(liveCount);

    
    res = struct;
    res.totalLive = liveCount;
    res.totalDead = deadCount;
    res.totalArea = totalCount;
    res.pA = pA;
    
    
    
    res.time = entityStruct.dataParameters.time; % todo: parametrize
    
    
end

end

function props = parseParams(v)
% default:
props = struct(...
    'cellArea','area', ...
    'liveDeadCount','ldcount', ...
    'mode', 'ratio', ...
    'deadRatioCutoff', 0.5 ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'cellArea'))
        props.cellArea = v{i+1};
    elseif (strcmp(v{i}, 'liveDeadCount'))
        props.liveDeadCount = v{i+1};
    elseif (strcmp(v{i}, 'mode'))
        props.mode = v{i+1};
    elseif (strcmp(v{i}, 'deadRatioCutoff'))
        props.deadRatioCutoff = v{i+1};
    end
end

end
