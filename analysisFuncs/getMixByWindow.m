function res = getMixByWindow(entities, parameters)

props = parseParams(parameters);

data = entities.data;

mask1 = data.(props.masks{1});
mask2 = data.(props.masks{2});

% todo: multiple window sizes

res = [];

for wi = 1:numel(props.windowSizes)
    
    
    windowSizeInPixels = ciel(props.windowSizes{wi} ./ (data.properties.pixelSize));
    
    window = ones(windowSizeInPixels);

    has1 = conv2(mask1, window, 'same');
    has2 = conv2(mask2, window, 'same');

    hasAny = sum(sum(has1 | has2));
    hasBoth = sum(sum(has1 & has2));
    
    aRes = struct('window', props.windowSizes{wi}, 'has1', has1, 'has2', has2, 'hasAny', hasAny, 'hasBoth', hasBoth);
    
    res = [res, aRes];
end


end

function props = parseParams(v)
% default:
props = struct(...
    'masks',{{'CellMask1','CellMask2'}},...
    'windowSizes',{{10 100 200}}...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'masks'))
        props.masks = v{i+1};
    elseif (strcmp(v{i}, 'windowSizes'))
        props.windowSizes = v{i+1};
    end
end

end