function res = thresholdByValue(data,parameters)

props = parseParams(parameters);

if isnumeric(props.threshold)
    th = props.threshold;
else
    if (isfield(props, props.threshold))
        th = (data.(props.threshold));
    else
        th = (data.properties.(props.threshold));
    end
end

res = data.(props.src) >= th;

if (props.fillHoles)
    res = imfill(res, 'holes');
end

end

function props = parseParams(v)
% default:
props = struct(...
    'src','R',...
    'threshold','Rth',...
    'fillHoles',true ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'threshold'))
        props.threshold = v{i+1};
    elseif (strcmp(v{i}, 'fillHoles'))
        props.fillHoles = v{i+1};        
    end
end

end

