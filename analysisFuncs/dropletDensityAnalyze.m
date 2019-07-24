function result = dropletDensityAnalyze(entities, parameters)

props = parseParams(parameters);

% get param names
fns = fieldnames(entities(1).dataParameters);

bins = [props.bins_begin logspace(props.bins_min,props.bins_max+props.bins_step,2+(props.bins_max - props.bins_min)/props.bins_step) props.bins_append];


% TODO: struct creation is messy...
for ei = numel(entities):-1:1
    res(ei) = entities(ei).dataProperties;
end

[res.val] = deal([]);

for ei = numel(entities):-1:1
    res(ei).val = getDropletDensityAnalyze(entities(ei), props);
    res(ei).val.params = entities(ei).dataProperties;
end

%nd = createNDResultTable(res, 'val', fns);
nd = NDResultTable(res, 'val', fns);

groupCounter = 0;

% TODO: use some func for this
% uniting similar datas
for ti = 1:numel(nd.T)
    if (~isempty(nd.T{ti}))
        vv = nd.T{ti}{1};
        vv.Ns = [];
        groupCounter = groupCounter + 1;
        vv.groupNum = groupCounter;
        for ri = 1:numel(nd.T{ti})
            areas = nd.T{ti}{ri}.dropletArea;
            totalArea = nd.T{ti}{ri}.totalPixels * vv.pA * props.convertFactor;
            [Ni] = histcounts(areas,bins) / totalArea;
            if (ri == 1)
                vv.Ns = Ni;
            else
                vv.dropletArea = [vv.dropletArea; areas];
                vv.Ns = [vv.Ns;Ni];
            end
        end
        vv.numGroups = numel(nd.T{ti});
        nd.T{ti} = cell(0);
        nd.T{ti}{1} = vv;
    end
end

Xcons = bins(1:end-1)*props.xOffset;

% TODO: and for this
for ti = 1:numel(nd.T)
    if (~isempty(nd.T{ti}))
        % actual work
        vv = nd.T{ti}{1};
        Ns = vv.Ns;
        Nmean = mean(Ns,1);
        Nmean(Nmean == 0) = nan;
        Nste = std(Ns,0,1) / sqrt(vv.numGroups);
        
        X = Xcons;
        Y = Nmean;
        Yerr = Nste;
    
        X = X(~isnan(Y));
        Yerr = Yerr(~isnan(Y));
        Y = Y(~isnan(Y));
    
        vv.X = X;
        vv.Y = Y;
        vv.Yerr = Yerr;
        
        nd.T{ti}{1} = vv;
    end
end

result = nd;


% TODO: and for removing dimension of size 1 (? but what will happen to a
% single data entry ?)

end

function res = getDropletDensityAnalyze(entityStruct, props)

pA = (entityStruct.dataParameters.pixelSize)^2;

dropletArea = entityStruct.(props.dropletArea) * pA;

res.dropletArea = dropletArea;
res.totalPixels = numel(entityStruct.seg);
res.pA = pA;

end

function props = parseParams(v)
% default:
props = struct(...
    'dropletArea','area', ...
    'dropletAreaBins',[1 10^2 10^3 10^4 10^5 inf], ...
    'bins_min', 1.25, ...
    'bins_max', 3.75, ...
    'bins_step', 0.5, ...
    'bins_begin', [], ...
    'bins_append', inf, ...
    'convertFactor', 10^-6, ...
    'xOffset', 10^0.25 ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'dropletArea'))
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
    elseif (strcmp(v{i}, 'bins_begin'))
        props.bins_begin = v{i+1};            
    elseif (strcmp(v{i}, 'convertFactor'))
        props.convertFactor = v{i+1};
    elseif (strcmp(v{i}, 'xOffset'))
        props.xOffset = v{i+1};
        
    end
end

end

