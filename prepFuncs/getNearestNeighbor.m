function res = getRipleysK(data,parameters)

props = parseParams(parameters);

imageSize = size(imBF_BW);

res = [];
end

function props = parseParams(v)
% default:
props = struct(...
    'src','GFP',...
    'validMask','removed',...
    'distBins',[0,power(2,0:8)],...
    'repeats', 100 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'static'))
        props.static = v{i+1};
    elseif (strcmp(v{i}, 'dynamic'))
        props.dynamic = v{i+1};
    elseif (strcmp(v{i}, 'distBins'))
        props.distBins = v{i+1};
    end
end

end
