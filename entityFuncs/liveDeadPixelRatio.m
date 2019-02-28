function [liveRatio] = liveDeadPixelRatio(entities, data, parameters)

props = parseParams(parameters);

Ilive = data.(props.liveIntensity);
Idead = data.(props.deadIntensity);


regions = entities.props.regions;

liveRatio = zeros(size(regions));

for i=1:numel(regions)
    pList = regions(i).PixelIdxList;
    totalCount = numel(pList);
    liveCount = sum(Ilive(pList) > Idead(pList));
    liveRatio(i) = liveCount / totalCount;
end


end


function props = parseParams(v)
% default:
props = struct(...
    'liveIntensity','G_minus_bg',...
    'deadIntensity','R_minus_bg'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'liveIntensity'))
        props.liveIntensity = v{i+1};
    elseif (strcmp(v{i}, 'deadIntensity'))
        props.deadIntensity = v{i+1};
    end
end

end

