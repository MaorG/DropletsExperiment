function res = thresholdByValue(data,parameters)

props = parseParams(parameters);

th = (data.properties.(props.threshold));

res = data.(props.src) >= th;

end

function props = parseParams(v)
% default:
props = struct(...
    'src','R',...
    'threshold','Rth'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'threshold'))
        props.threshold = v{i+1};
    end
end

end

