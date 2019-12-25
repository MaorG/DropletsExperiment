function res = masks2Label(data,parameters)

props = parseParams(parameters);

maskNamesAndLabels = props.masks;

masks = {};
labels = [];
for mi = 1:numel(maskNamesAndLabels)
    masks{mi} = data.(maskNamesAndLabels{mi}{1});
    labels(mi) = maskNamesAndLabels{mi}{2};
end

res = zeros(size(masks{1}));

for mi = 1:numel(masks)
    res(masks{mi}) = labels(mi);
end

end

function props = parseParams(v)
% default:
props = struct(...
    'masks',{{'LiveMask' 1}}...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'masks'))
        props.masks = v{i+1};
    end
end

end