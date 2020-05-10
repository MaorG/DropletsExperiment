function res = thresholdByValue(data,parameters)

props = parseParams(parameters);

if isnumeric(props.threshold)
    th = props.threshold;
else
    if (isprop(data, props.threshold))
        th = (data.(props.threshold));
    else
        th = (data.properties.(props.threshold));
    end
end

if isfield(data,(props.src))
    src = data.(props.src);
elseif ischar(data.properties.(props.src))
    src = data.(data.properties.(props.src));
end

res = (src >= th);

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

