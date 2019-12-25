function mask = classifyByFluorescenseTemp(data, parameters)

props = parseParams(parameters);

bactChannel = data.(data.properties.bactChannel);
otherChannel = data.(data.properties.otherChannel);
bactThresh = data.properties.bactThresh;
otherThresh = data.properties.otherThresh;
originalMask = data.(props.originalMask);


[h,w] = size(originalMask);

mask = originalMask & (bactChannel > bactThresh);
mask = mask & (otherChannel < otherThresh);

if props.verbose
    figure
    RGB = data.(props.RGBsrc);
    imshow(RGB)
    hold on
    BlueI =  cat(3, zeros(h,w), zeros(h,w), ones(h,w));
    hb = imshow(BlueI);
    set(hb, 'AlphaData', bwperim(originalMask));
    RedI = cat(3, ones(h,w), zeros(h,w), zeros(h,w));
    hr = imshow(RedI);
    set(hr, 'AlphaData', bwperim(mask));
end

end

function props = parseParams(v)
% default:
props = struct(...
    'originalMask','allMask',...
    'RGBsrc','RGB',...
    'verbose','0'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'originalMask'))
        props.originalMask = v{i+1};
    elseif (strcmp(v{i}, 'RGBsrc'))
        props.RGBsrc = v{i+1};
    elseif (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};
    end
end

end
