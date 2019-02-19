function res = subtractMean(data,parameters)

props = parseParams(parameters);

meanVal = mean(data.(props.sub));

res = data.(props.src) - meanVal;

end

function props = parseParams(v)
% default:
props = struct(...
    'src','RName',...
    'sub','Rbg'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'sub'))
        props.sub = v{i+1};
    end
end

end

