function result = getSurfaceCoverage(entities, parameters)

props = parseParams(parameters);




% get param names
fns = fieldnames(entities(1).dataParameters);

% TODO: struct creation is messy...
for ei = numel(entities):-1:1
    res(ei) = entities(ei).dataParameters;
end

[res.val] = deal([]);

for ei = numel(entities):-1:1
    
    data = entities(ei).dataHandle;
    areaFactor = 1;
    if (~isempty(props.removedMaskName) && sum(strcmp(fieldnames(data),props.removedMaskName)) > 0);
        removedMask = data.(props.removedMaskName);
        if (~isempty(removedMask))
            areaFactor = 1.0 - sum(removedMask(:))/numel(removedMask);
        end

    end

    image = entities(ei).seg;
    coverage = sum(image(:))/numel(image);
    coverage = coverage/areaFactor;
    res(ei).val = coverage;
end

%nd = createNDResultTable(res, 'val', fns);
nd = NDResultTable(res, 'val', fns);

if (~isempty(props.colateBy))
    dim = find(strcmp(nd.names,props.colateBy));
    vals = nd.vals{dim};
    nd = nd.colateTable(nd,(props.colateBy));
    
end

% TODO: use some func for this - simple concatanation...
for ti = 1:numel(nd.T)
    if (~isempty(nd.T{ti}))
        vv = nd.T{ti}{1};
        for ri = 2:numel(nd.T{ti})
            vv = cat(1, vv, nd.T{ti}{ri});
        end
        %             nd.T{ti} = cell(0);
        %             nd.T{ti}{1} = vv;
        if (~isempty(props.colateBy))
            a = struct;
            a.Y = vv; 
            a.X = vals; 
            
            nd.T{ti} = {a};
        else
            nd.T{ti} = vv;
        end
    end
end


result = nd;

end

function props = parseParams(v)
% default:
props = struct(...
    'removedMaskName','removed',...
    'colateBy', []...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'removedMaskName'))
        props.removedMaskName = v{i+1};
    elseif (strcmp(v{i}, 'colateBy'))
        props.colateBy = v{i+1};
    end
end

end
