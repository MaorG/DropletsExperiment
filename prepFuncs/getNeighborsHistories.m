function res = getNeighborsHistories(data,parameters)

if isfield(data.properties, 'next')
    res = [];
    return;
end

props = parseParams(parameters);

pixelSize = data.properties.pixelSize;
maxDist = props.maxDist / pixelSize;
windowSize = props.windowSize / pixelSize;
mask1 = data.(props.mask1);
mask2 = data.(props.mask2);
RGB = data.(props.image);

imageSize = size(mask1);

se = strel('disk',ceil(maxDist*0.5));

expand1 = imdilate(mask1,se);
expand2 = imdilate(mask2,se);
intersection = expand1 & expand2;
intersection = intersection | expand2;

CC = bwconncomp(intersection);
rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
centers = cat(1, rp.Centroid);

res = struct;
res.windows = {};
res.x = [];
res.y = [];

for ci = 1:min(100,size(centers,1))
    center = centers(ci,:);
    cx = ceil(center(1));
    cx = min(max(1,cx),imageSize(2));
    cy = ceil(center(2));
    cy = min(max(1,cy),imageSize(1));
    
    cxmin = max(cx-ceil(windowSize*0.5),1);
    cxmax = min(cx+ceil(windowSize*0.5),imageSize(2));
    cymin = max(cy-ceil(windowSize*0.5),1);
    cymax = min(cy+ceil(windowSize*0.5),imageSize(1));
    
    %window = mask1(cymin:cymax,cxmin:cxmax) + 2*mask2(cymin:cymax,cxmin:cxmax);
    window = RGB(cymin:cymax,cxmin:cxmax,:);
    
    currData = data;
    while(isfield(currData.properties,'prev'))
        currData = currData.properties.prev;
        currmask1 = currData.(props.mask1);
        currmask2 = currData.(props.mask2);
        
        %border = 5*ones(size(window,1),1);
        %window = cat(2,window, border, currmask1(cymin:cymax,cxmin:cxmax) + 2*currmask2(cymin:cymax,cxmin:cxmax));
        
        currRGB = currData.(props.image);
        border = zeros(size(window,1),1,3);
        
        info = [num2str(currData.parameters.time) ]
        position = [0,0];
        wind = currRGB(cymin:cymax,cxmin:cxmax,:);
        wind = insertText(wind,position,info,'TextColor','white','FontSize',18, 'BoxColor', 'black');
    
        window = cat(2,window, border, wind);

    end

    res.windows{end+1} = window;
    res.x(end+1) = cx;
    res.y(end+1) = cy;
    res.dataParameters = data.parameters;
%    figure;
    %imshow(label2rgb(window));
%    imshow(window);
    
    
end






end


function props = parseParams(v)
% default:
props = struct(...
    'maxDist', 2, ...
    'windowSize',30,...
    'mask2','BF', ...
    'mask1', 'GFP', ...
    'image', 'RGB' ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'maxDist'))
        props.maxDist = v{i+1};
    elseif (strcmp(v{i}, 'windowSize'))
        props.windowSize = v{i+1};
    elseif (strcmp(v{i}, 'mask2'))
        props.mask2 = v{i+1};
    elseif (strcmp(v{i}, 'mask1'))
        props.mask1 = v{i+1};
    elseif (strcmp(v{i}, 'image'))
        props.image = v{i+1};
    end
    end7

end
