function res = getPixelCount(data,parameters)

% parameters:
% src1: fieldname in data, 1st image
% src2: fieldname in data, 2nd image
% op: choose from {'union', 'diff', 'intersect'}

props = parseParams(parameters);

s = data.(props.src);

res = numel(s(:));

end

function props = parseParams(v)
% default:
props = struct(...
    'src','BF'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    end
end

end

