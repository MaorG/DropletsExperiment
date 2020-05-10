function subsetMask = getMaskSubset(data, parameters)
props = parseParams(parameters);

pixelSize = data.properties.pixelSize;
mask = data.(props.src1);
if isnumeric(props.subsetSize)
    subsetSize = props.subsetSize;
else
    subsetSize = data.(props.subsetSize);
end

CC = bwconncomp(mask);
rp = regionprops(CC, 'PixelIdxList', 'Area');
areas = cat(1,rp.Area);
if (props.randomSeed>0)
    rng(props.randomSeed);
end
rp = rp(areas>=props.minArea);
rndindices = randperm(numel(rp));
rndincices = rndindices(1:min(subsetSize,numel(rndindices)));
subsetMask = mask*0;

for ri = rndincices
    subsetMask(rp(ri).PixelIdxList) = 1;
end

end

function props = parseParams(v)
% default:
props = struct(...
    'src1','',...
    'randomSeed', 0,...
    'minArea', 0,...
    'subsetSize', 10 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src1'))
        props.src1 = v{i+1};
    elseif (strcmp(v{i}, 'randomSeed'))
        props.randomSeed = v{i+1};
    elseif (strcmp(v{i}, 'minArea'))
        props.minArea = v{i+1};
    elseif (strcmp(v{i}, 'subsetSize'))
        props.subsetSize = v{i+1};
    end
end

end
