function res = removeOverlappingRegions(data,parameters)

% parameters:
% src1: fieldname in data, 1st image
% src2: fieldname in data, 2nd image
% op: choose from {'union', 'diff', 'intersect'}

props = parseParams(parameters);
dX = data.properties.pixelSize;
s1 = data.(props.src1) > 0;
s2 = data.(props.src2) > 0;

if props.maxSizeToRemove > numel(s1)
    s1large = zeros(size(s1));
else
s1large = bwareaopen(s1, floor(props.maxSizeToRemove/(dX * dX)));
end
s1small = s1 & ~s1large;

intersect = s1small&s2;

toDelete = imfill(~s1,find(intersect(:)));

res = (s1 & (~toDelete));

end

function props = parseParams(v)
% default:
props = struct(...
    'src1','Rmask',...
    'src2','Gmask',...
    'maxSizeToRemove','3'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src1'))
        props.src1 = v{i+1};
    elseif (strcmp(v{i}, 'src2'))
        props.src2 = v{i+1};
    elseif (strcmp(v{i}, 'maxSizeToRemove'))
        props.maxSizeToRemove = v{i+1};
    end
end

end

