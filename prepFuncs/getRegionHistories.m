function res = getRegionHistories(data,parameters)

if isfield(data.properties, 'next')
    res = [];
    return;
end

props = parseParams(parameters);

pixelSize = data.properties.pixelSize;
RGB = data.(props.image);

imageSize = size(RGB);
imageSize = imageSize(1:2);

regions = getRegions(props.regions,pixelSize,imageSize);

mask1 = [];
if (~isempty(props.mask1))
    mask1 = data.(props.mask1);
end
mask2 = [];
if (~isempty(props.mask2))
    mask2 = data.(props.mask2);
end

RGB = data.(props.image);


res = struct;
res.windows = {};
res.x = [];
res.y = [];



for ri = 1:numel(regions)
   
    region = regions(ri);
    window = getWindow(RGB, mask1, mask2, region, data.properties);
    
    currData = data;
    while(isfield(currData.properties,'prev'))
        currData = currData.properties.prev;
        currmask1 = currData.(props.mask1);
        currmask2 = currData.(props.mask2);
        currRGB = currData.(props.image);
        currWindow = getWindow(currRGB, currmask1, currmask2, region, currData.properties);
        
        border = zeros(size(window,1),1,3);

        window = cat(2,window, border, currWindow);

    end

    res.windows{end+1} = window;
    res.x(end+1) = region.x1;
    res.y(end+1) = region.y1;
    res.dataParameters = data.parameters;
%    figure;
    %imshow(label2rgb(window));
%    imshow(window);
    
    
end

end

function window = getWindow(image, mask1, mask2, region, properties)
    
    
    cxmin = region.x1;
    cxmax = region.x2;
    cymin = region.y1;
    cymax = region.y2;
    window = image(cymin:cymax,cxmin:cxmax,:);
    mask1w = mask1(cymin:cymax,cxmin:cxmax,:);
    mask2w = mask2(cymin:cymax,cxmin:cxmax,:);
    if size(window,3) == 1
        window = repmat(window,1,1,3);
    end
    windowR = window(:,:,1);
    windowG = window(:,:,2);
    windowB = window(:,:,3);

%     mask1w = bwperim(mask1w);
%     mask2w = bwperim(mask2w);

    windowR(mask1w > 0) = 2^16-1;
    windowB(mask2w > 0) = 2^16-1;
    
    window = cat(3,windowR,windowG,windowB);
    
    info = [num2str(properties.time)];
    position = [0,0];
    window = insertText(window,position,info,'TextColor','white','FontSize',18, 'BoxColor', 'black');


end

function regionList = getRegions(regions,pixelSize, imageSize);

% set default props

default = struct(...
    'units', 'pixels',...
    'x',1000,'y',1000,...
    'w',600, 'h',600,...
    'dx',0,  'dy',0',...
    'nx',1,  'ny',1 ...
);    

default_fns = fieldnames(default);

for fn = default_fns'
    if ~isfield(regions,fn{1})
        regions.(fn{1}) = default.(fn{1})
    end
end

if strcmp(regions.units,'um')
    regions.x = regions.x / pixelSize;
    regions.y = regions.y / pixelSize;
    regions.w = regions.w / pixelSize;
    regions.h = regions.h / pixelSize;
    regions.dx = regions.dx / pixelSize;
    regions.dy = regions.dy / pixelSize;
end

regionList = []
for i = 1:regions.nx
    for j = 1:regions.ny
        regionEntry = struct;
        regionEntry.x1 = regions.x + (i - 1) * (regions.w + regions.dx);
        regionEntry.y1 = regions.y + (j - 1) * (regions.h + regions.dy);
        regionEntry.x2 = regionEntry.x1 + regions.w;
        regionEntry.y2 = regionEntry.y1 + regions.h;
        if regionEntry.x2 > imageSize(2)
            regionEntry.x2 = imageSize(2);
        end
        if regionEntry.y2 > imageSize(1)
            regionEntry.y2 = imageSize(1);
        end
        if regionEntry.x1 > imageSize(2) || regionEntry.y1 > imageSize(1)
            regionEntry = [];
        end
        if (~isempty(regionEntry))
            if isempty(regionList)
                regionList = regionEntry;
            else
                regionList(end+1) = regionEntry;
            end
        end
    end
end



end

function props = parseParams(v)
% default:
props = struct(...
    'regions', [], ...
    'mask2','BF', ...
    'mask1', 'GFP', ...
    'image', 'RGB' ...
    );


for i = 1:numel(v)
    
    if (strcmp(v{i}, 'regions'))
        props.regions = v{i+1};
    elseif (strcmp(v{i}, 'mask2'))
        props.mask2 = v{i+1};
    elseif (strcmp(v{i}, 'mask1'))
        props.mask1 = v{i+1};
    elseif (strcmp(v{i}, 'image'))
        props.image = v{i+1};
    end
end

end
