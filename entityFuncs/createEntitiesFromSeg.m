function [entityProps] = createEntitiesFromSeg(entities, data, parameters)

props = parseParams(parameters);

seg = data.(props.seg);

s = regionprops(seg,props.properties);

entityProps.seg = seg;
entityProps.regions = s;

end


function props = parseParams(v)
% default:
props = struct(...
    'seg','CellMask',...
    'properties','pixelIdxList'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'seg'))
        props.seg = v{i+1};
    elseif (strcmp(v{i}, 'properties'))
        props.properties = v{i+1};
    end
end

end

