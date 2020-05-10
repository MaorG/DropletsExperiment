function count = getMaskRegionCount(data, parameters)

props = parseParams(parameters);
mask = data.(props.src1);

CC = bwconncomp(mask);
rp = regionprops(CC, 'PixelIdxList', 'Area');

count = numel(rp);
end

function props = parseParams(v)
% default:
props = struct(...
    'src1','',...
    'randomSeed', 0,...
    'subsetSize', 10 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src1'))
        props.src1 = v{i+1};
    elseif (strcmp(v{i}, 'randomSeed'))
        props.randomSeed = v{i+1};
    elseif (strcmp(v{i}, 'subsetSize'))
        props.subsetSize = v{i+1};
    end
end

end
