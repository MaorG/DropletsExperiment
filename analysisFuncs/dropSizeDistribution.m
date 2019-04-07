function result = dropSizeDistribution(entities, parameters)
% dropSizeDistribution
% calculates droplet size distribution
% this func expects pixelCount fields in the entities... :(
% todo: see line above - any smart solution?

% math: 
% for each FoV the number of droplets in each bin is divided by total area,
% giving us the density
% identical FoVs are combined by weight, proportional to their area




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
        res(ei).val = entities(ei).(props.dropArea)*pA;
        res(ei).totArea = entities(ei).pixelCount*pA;
    end
    
    nd = NDResultTable(res, 'val', fns);
    ndta = NDResultTable(res, 'totArea', fns);
    
    bins = props.dropletAreaBins;% [0,logspace(props.bins_min,props.bins_max+props.bins_step,2+(props.bins_max - props.bins_min)/props.bins_step)];
    totalArea = entities(ei).pixelCount
    
    
    for ti = 1:numel(nd.T)
        if (~isempty(nd.T{ti}))
            weights = ones(size(nd.T{ti}));
            NiDensity = zeros(numel(nd.T{ti}),numel(bins)-1);
            for ri = 1:numel(nd.T{ti})
               areas = nd.T{ti}{ri};
               totArea = ndta.T{ti}{ri};
               
               [Ni,~,binidx] = histcounts(areas,bins);
               
               NiDensity(ri,:) = (Ni / totArea) *10^6 % mm^2 vs um^2 :(((
               weights(ri) = totArea;
               
            end
            
            NDensity
            nd.T{ti} = cell(0);
            nd.T{ti}{1} = vv;
        end
    end

    
    % TODO: and for this a simple cellfunc would do...
	for ti = 1:numel(nd.T)
        if (~isempty(nd.T{ti}))
            areas = nd.T{ti}{1};
            totAreaInBins = [];
            [Ni,~,binidx] = histcounts(areas,bins);

            relAreaInBins = totAreaInBins / sum(totAreaInBins);
            
            vva = struct('X', bins(1:end-1), 'Y', relAreaInBins);
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
    'dropArea','area', ...
    'dropletAreaBins',[1 10^1.75 10^2.25 10^2.75 10^3.25 10^3.75 10^4.25 inf] ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'dropArea'))
        props.dropArea = v{i+1};
    elseif (strcmp(v{i}, 'dropletAreaBins'))
        props.dropletAreaBins = v{i+1};
    end
end

end


