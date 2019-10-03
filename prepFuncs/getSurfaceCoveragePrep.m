function res = getSurfaceCoveragePrep(data,parameters)

props = parseParams(parameters);
image = data.(props.src);

res = sum(image(:))/numel(image);

end

function props = parseParams(v)
% default:
props = struct(...
    'src','GFP' ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    end
end

end