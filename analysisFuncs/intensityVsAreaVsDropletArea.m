function result = intensityVsAreaVsDropletArea(entities, parameters)

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
        dropArea = zeros(size(entities(ei).(props.dropArea)));
        dropAreaCellArray = entities(ei).(props.dropArea);
        for cellIdx = 1:numel(dropAreaCellArray)
           if (~isempty(dropAreaCellArray{cellIdx}))
               dropArea(cellIdx) = dropAreaCellArray{cellIdx}(1);
           end
        end
        area = entities(ei).(props.cellArea);
        
        area = area*pA;
        dropArea = dropArea*pA;
        intensity = entities(ei).(props.intensity);
        res(ei).val = cat(2, area, dropArea, intensity);
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
% 	for ti = 1:numel(nd.T)
%         if (~isempty(nd.T{ti}))
%             areas = nd.T{ti}{1};
%             
%             totAreaInBins = [];
%             [Ni,~,binidx] = histcounts(areas,bins);
%             for bi = 1:numel(Ni)
%                 totAreaInBins(bi) = sum(areas(binidx==bi));
%             end
%             relAreaInBins = totAreaInBins / sum(totAreaInBins);
%             
%             vva = struct('X', bins(1:end-1), 'Y', relAreaInBins);
%             nd.T{ti}{1} = vva;
%         end
%     end
%     
    result = nd;

    % TODO: and for removing dimension of size 1 (? but what will happen to a
    % single data entry ?)
    
end

function props = parseParams(v)
% default:
props = struct(...
    'cellArea','area', ...
    'dropArea','dArea', ...
    'intensity','meanBioRep' ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'cellArea'))
        props.cellArea = v{i+1};
    elseif (strcmp(v{i}, 'dropArea'))
        props.dropArea = v{i+1};
    elseif (strcmp(v{i}, 'intensity'))
        props.intensity = v{i+1};
    end
end

end


