function result = getSurfaceCoverageVsTime(entities, parameters)
    
   
        
    % get param names
    fns = fieldnames(entities(1).dataParameters);
    
    % TODO: struct creation is messy...
    for ei = numel(entities):-1:1
        res(ei) = entities(ei).dataParameters;
    end 
    
    [res.val] = deal([]);
    
    for ei = numel(entities):-1:1
        
        image = entities(ei).seg;
        coverage = sum(image(:))/numel(image);
        
        res(ei).val = struct
        res(ei).val.Y = coverage;
        res(ei).val.X = entities(ei).dataParameters.time;
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
%             nd.T{ti} = cell(0);
%             nd.T{ti}{1} = vv;
nd.T{ti} = vv;
        end
    end


    result = nd;
    
end