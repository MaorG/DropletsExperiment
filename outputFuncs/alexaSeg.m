function res = alexaSeg(data,parameters)
    
    props = parseParams(parameters);
    
    s = data.(props.src);

    res = [];
end

function props = parseParams(v)
% default:
props = struct(...
    'src','I',...
    'thresh','6'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'thresh'))
        props.dist = v{i+1};

    end
end

end