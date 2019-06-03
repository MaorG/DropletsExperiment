function res = maskByLabel(data,parameters)

props = parseParams(parameters);

map = data.(props.map);
val = (props.value);

res = (map == val);

end

function props = parseParams(v)
% default:
props = struct(...
    'map','labelMap',...
    'value','1' ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'map'))
        props.map = v{i+1};
    elseif (strcmp(v{i}, 'value'))
        props.value = v{i+1};
    end
end

end