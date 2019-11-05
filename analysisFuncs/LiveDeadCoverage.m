function result = LiveDeadCoverage(entities, parameters)

    props = parseParams(parameters);
        
    % get param names
    fns = fieldnames(entities(1).dataParameters);
    
    % TODO: struct creation is messy...
    for ei = numel(entities):-1:1
        res(ei) = entities(ei).dataParameters;
    end 
    
    [res.val] = deal([]);
    
    for ei = numel(entities):-1:1
        res(ei).val = getLiveDeadCoverageAux(entities(ei), props);
        
        % save data parameters too in val to later reference them for
        % customization of each plot according to parameters
        for i = 1 : numel(fns)
            res(ei).val.dataParameters.(fns{i}) = res(ei).(fns{i});
        end
        
    end
    
    %nd = createNDResultTable(res, 'val', fns);
    nd = NDResultTable(res, 'val', fns);
    
    % COMBINING DUPLICATES
    for ti = 1:numel(nd.T)
        if (~isempty(nd.T{ti}))
            vv = nd.T{ti}{1};
            for ri = 2:numel((nd.T{ti}))
               vv.totalArea = [vv.totalArea, nd.T{ti}{ri}.totalArea];
               vv.liveArea = [vv.liveArea, nd.T{ti}{ri}.liveArea];
               vv.deadArea = [vv.deadArea, nd.T{ti}{ri}.deadArea];
            end
            nd.T{ti}{1} = vv;
        end
    end
    % HANDLING TIME SERIES
    nd = nd.colateTable(nd, 'time');
    
    % TODO: use some func for this
    % uniting similar datas
    for ti = 1:numel(nd.T)
        if (~isempty(nd.T{ti}))
            
            totalArea = {};
            liveArea = {};
            deadArea = {};
            timePoints = [];
            for tpi = 1:numel(nd.T{ti})
                totalArea{tpi} = nd.T{ti}{tpi}.totalArea;
                liveArea{tpi} = nd.T{ti}{tpi}.liveArea;
                deadArea{tpi} = nd.T{ti}{tpi}.deadArea;
                timePoints(tpi) = nd.T{ti}{tpi}.time;
            end
            te = struct;
            te.totalArea = totalArea;
            te.liveArea = liveArea;
            te.deadArea = deadArea;
            te.timePoints = timePoints;

            nd.T{ti} = cell(0);
            nd.T{ti}{1} = te;
        end
    end

    % TODO: and for this
% 	for ti = 1:numel(nd.T)
%         if (~isempty(nd.T{ti}))
%             % actual work
%             vv = nd.T{ti}{1};
%             area = vv.area;
%             pop = vv.pop;
%             [areaSorted, areaOrder] = sort(area);
%             popSorted = pop(areaOrder);
%             popFracSorted = cumsum(popSorted,'reverse') ./ sum(popSorted);
%             
%             vv.X = areaSorted;
%             vv.Y = popFracSorted;
%             
%             nd.T{ti}{1} = vv;
%         end
%     end



result = nd;
    
end

function res = getLiveDeadCoverageAux(entityStruct, props)

pA = (entityStruct.dataParameters.pixelSize)^2;

map = entityStruct.data.(props.map);
totalArea = numel(map)*pA;
liveArea = sum(map(:) == 1)*pA;
deadArea = sum(map(:) == 2)*pA;

res.totalArea = totalArea;
res.liveArea = liveArea;
res.deadArea = deadArea;
if isfield(entityStruct.dataParameters, 'time')
    res.time = entityStruct.dataParameters.time; 
else
    res.time = nan;
end
end

function props = parseParams(v)
% default:
props = struct(...
    'map','LiveDeadMap' ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'map'))
        props.map = v{i+1};
    end
end

end
