function [res] = getFieldFromData(entities, data, parameters)

props = parseParams(parameters);

% TODO: handle data.properties fields...

res = data.(props.fieldName);

end


function props = parseParams(v)
% default:
props = struct(...
    'fieldName','pixelCount'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'fieldName'))
        props.fieldName = v{i+1};
    end
end

end

