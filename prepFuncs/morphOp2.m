function res = morphOp2(data,parameters)

% parameters:
% src: fieldname in data, 1st image
% op: choose from {'dilate', 'erode', 'open', 'close'}
% dist: SE radius

props = parseParams(parameters);

dX = data.properties.pixelSize;

s = data.(props.src)>0;

    
% the following part allows custom distances per different wells, timepoints, etc.
% example: 'DropMaskF', 'morphOp', {'src' 'DropMaskU' 'op' 'areaOpen' 'dist' {'param' 'time' 1 300 2 150}}
dist = props.dist;
paramPos = find(strcmpi(dist, 'param'));
if (~isempty(paramPos))
    paramPos = paramPos(1) + 1;
    if (paramPos <= numel(dist))
        param = dist{paramPos};
    end
    paramPos = paramPos + 1; % all tokens afterwards are the distances for each parameter value

    paramVal = data.parameters.(param);
    for i = paramPos : 2 : numel(dist)
        curParamVal = dist{i};
        curParamDist = dist{i + 1};
        if ((isnumeric(paramVal) && curParamVal == paramVal) || (~isnumeric(paramVal) && any(strcmpi(paramVal, curParamVal))))
            distVal = curParamDist;
        end
    end
    dist = distVal;
end


disk = getDisk(floor(dist / dX));

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
    res = bwareaopen(s,floor(dist / (dX * dX)));
elseif strcmp(props.op, 'fillHoles')
    res = imfill(s, 'holes');
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
    'dist',6,...
    'distVal',6,... % same value as for dist, used when parameters are used in the 'dist' parameter
    'op','dilate',...
    'distParam', 'time' ...
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

