function [intensity] = getMeanIntensity(entities, data, parameters)

props = parseParams(parameters);

Imask = data.(props.mask);
Imap = data.(props.map);

Ivalue = double(Imask).*double(Imap);

regions = entities.regions;

intensity = zeros(size(regions));

for i=1:numel(regions)
    pList = regions(i).PixelIdxList;
    totalCount = numel(pList);
    intensity(i) = sum(Ivalue(pList)) / totalCount;
end

end


function props = parseParams(v)
% default:
props = struct(...
    'mask','LiveMask',...
    'map','GFP',...
    'threshold', 'GFPth' ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'mask'))
        props.mask = v{i+1};
    elseif (strcmp(v{i}, 'map'))
        props.map = v{i+1};
    elseif (strcmp(v{i}, 'threshold'))
        props.threshold = v{i+1};
    end
end

end

