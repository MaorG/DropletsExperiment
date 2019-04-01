function res = morphOp(data,parameters)

% parameters:
% src: fieldname in data, 1st image
% op: choose from {'dilate', 'erode', 'open', 'close'}
% dist: SE radius

props = parseParams(parameters);

dX = data.properties.pixelSize;

s = data.(props.src)>0;

disk = getDisk(floor(props.dist / dX));

SE = strel('arbitrary',disk);

if strcmp(props.op, 'dilate')
    res = imdilate(s, SE);
elseif strcmp(props.op, 'erode')
    res = imerode(s, SE);
elseif strcmp(props.op, 'open')
    res = imopen(s, SE);
elseif strcmp(props.op, 'close')
    res = imclose(s, SE);
elseif strcmp(props.op, 'areaOpen')
    res = bwareaopen(s,floor(props.dist / (dX * dX)));
end

end


function disk = getDisk(radius)
    dx = -radius:radius;
    dy = -radius:radius;
    [DX, DY] = meshgrid(dx,dy);
    disk = (DX.*DX)+(DY.*DY) <= radius*radius;
end

function props = parseParams(v)
% default:
props = struct(...
    'src','RMask',...
    'dist','6',...
    'op','dilate'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'dist'))
        props.dist = v{i+1};
    elseif (strcmp(v{i}, 'op'))
        props.op = v{i+1};
    end
end

end

