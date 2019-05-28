function result = dropletAreaVsPopulationArea(entities, parameters)

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
        dropArea = entities(ei).(props.dropArea);
        popArea = zeros(size(entities(ei).(props.dropArea)));
        popAreaCellArray = entities(ei).(props.popArea);
        for cellIdx = 1:numel(popAreaCellArray)
            popArea(cellIdx) = sum(sum(popAreaCellArray{cellIdx}));
        end
        area = entities(ei).(props.popArea);
        
        dropArea = dropArea*pA;
        popArea = popArea*pA;
        res(ei).val = struct('pop', popArea, 'drop', dropArea);
    end
    
    %nd = createNDResultTable(res, 'val', fns);
    nd = NDResultTable(res, 'val', fns);
    
    % TODO: use some func for this - simple concatanation...
    for ti = 1:numel(nd.T)
        if (~isempty(nd.T{ti}))
            vv = nd.T{ti}{1};
            for ri = 2:numel(nd.T{ti})
               vv = cat(1, vv, nd.T{ti}{ri});
            end
            nd.T{ti} = cell(0);
            nd.T{ti}{1} = vv;
        end
    end

%     bins = [0,logspace(props.bins_min,props.bins_max+props.bins_step,2+(props.bins_max - props.bins_min)/props.bins_step)];
%     % TODO: and for this a simple cellfunc would do...

    bins = props.popBins;
	for ti = 1:numel(nd.T)
        if (~isempty(nd.T{ti}))
            drop = nd.T{ti}{1}.drop;
            pop = nd.T{ti}{1}.pop;
            
            totAreaInBins = [];
            [Ni,~,binidx] = histcounts(pop,bins);
            for bi = 1:numel(Ni)
                AreaInBinsMean(bi) = mean(drop(binidx==bi));
                AreaInBinsSTE(bi) = std(drop(binidx==bi))/sqrt(numel(drop(binidx==bi)));
            end
            %relAreaInBins = totAreaInBins / sum(totAreaInBins);
            
            vva = struct('X', bins(1:end-1), 'Y', AreaInBinsMean, 'Yste', AreaInBinsSTE);
            nd.T{ti}{1} = vva;
        end
    end
    
    result = nd;

    % TODO: and for removing dimension of size 1 (? but what will happen to a
    % single data entry ?)
    
end

function props = parseParams(v)
% default:
props = struct(...
    'popArea','cArea', ...
    'dropArea','area', ...
    'popBins', power(10,0:4) ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'popArea'))
        props.popArea = v{i+1};
    elseif (strcmp(v{i}, 'dropArea'))
        props.dropArea = v{i+1};
    elseif (strcmp(v{i}, 'popBins'))
        props.popBins = v{i+1};
    end
end

end


