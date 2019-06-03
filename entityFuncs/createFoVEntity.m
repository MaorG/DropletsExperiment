function [entityProps] = createFoVEntity(entities, data, parameters)

props = parseParams(parameters);

seg = data.(props.FoV);

s = struct('Area', numel(seg));

entityProps.data = data;
entityProps.regions = s;

end


function props = parseParams(v)
% default:
props = struct(...
    'FoV','CellMask'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'FoV'))
        props.seg = v{i+1};
    end
end

end

