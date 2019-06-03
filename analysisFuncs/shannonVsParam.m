function result = shannonVsParam(entities, parameters)

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
        xParam = entities(ei).(props.xParam)*pA;
        total = zeros(size(xParam));
        categories = zeros(size(xParam,1),size(entities(ei).(props.shannonCategories){1},2));
        ratios = zeros(size(categories));
        shannon = zeros(size(xParam));
        
        for xIdx = 1:numel(xParam)
            sc = entities(ei).(props.shannonCategories){xIdx};
            categories(xIdx,:) = sum(sc,1);
            total(xIdx) = sum(categories(xIdx,:),2);
            ratios(xIdx,:) = categories(xIdx,:)./total(xIdx);
            
            shannon(xIdx) = computeShannonForRatios(ratios(xIdx,:));
        end
        
        res(ei).val = struct('x', xParam, 'y', shannon);
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


    result = nd;
    
end

function res = computeShannonForRatios(ratios)
    res = 0;
    for i = 1:numel(ratios)
        p = ratios(i);
        h = -p*log2(p);
        if isnan(h)
            h = 0;
        end
        res = res + h;
    end
end

function props = parseParams(v)
% default:
props = struct(...
    'xParam','area', ...
    'shannonCategories', 'cLDCount' ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'xParam'))
        props.xParam = v{i+1};
    elseif (strcmp(v{i}, 'shannonCategories'))
        props.shannonCategories = v{i+1};
    end
end

end


