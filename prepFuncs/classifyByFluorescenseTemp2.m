function mask = classifyByFluorescenseTemp2(data, parameters)

props = parseParams(parameters);


bactChannel = data.(data.properties.bactChannel);
otherChannel = data.(data.properties.otherChannel);
bactThresh = data.properties.bactThresh;
otherThresh = data.properties.otherThresh;
originalMask = data.(props.originalMask);

[h,w] = size(originalMask);


if (numel(bactThresh) == 1)
    mask = originalMask & (bactChannel > bactThresh);
    mask = mask & (otherChannel < otherThresh);
else
    
    point1 = [bactThresh(1), otherThresh(1)];
    point2 = [bactThresh(2), otherThresh(2)];
    
    slope = (point1(2)-point2(2))/(point1(1) - point2(1));
    intersect = -slope*point1(1) + point1(2);
    
    Y = bactChannel*slope + intersect;
    mask = originalMask & (Y>otherChannel) & (bactChannel > min(bactThresh(:)));
end



if props.verbose
    %     figure
    %     RGB = data.(props.RGBsrc);
    %     imshow(RGB)
    %     hold on
    %     BlueI =  cat(3, zeros(h,w), zeros(h,w), ones(h,w));
    %     hb = imshow(BlueI);
    %     set(hb, 'AlphaData', bwperim(originalMask));
    %     RedI = cat(3, ones(h,w), zeros(h,w), zeros(h,w));
    %     hr = imshow(RedI);
    %     set(hr, 'AlphaData', bwperim(mask));
    
    figure
    RGB = data.(props.RGBsrc);
    imshow(cat(3,RGB+mask,RGB+originalMask-mask,RGB));
    
    %val = (originalMask) & (Y > otherChannel)  & (bactChannel > min(bactThresh(:)));

    colorbar;
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
