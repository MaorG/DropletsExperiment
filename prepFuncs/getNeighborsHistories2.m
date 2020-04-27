function res = getNeighborsHistories2(data,parameters)

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

se = strel('disk',ceil(maxDist));
disk = fspecial('disk',ceil(maxDist))
expand1 = imdilate(mask1,disk>0);

%expand1 = imdilate(mask1,se);
%expand2 = imdilate(mask2,se);
intersection = expand1 & mask2;
%intersection = intersection | expand2;

CC = bwconncomp(mask2);
rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
centers = cat(1, rp.Centroid);

inDistIndices = [];
for ci = 1:size(centers,1)
    if any(intersection(rp(ci).PixelIdxList))
        inDistIndices(end+1) = ci;
    end
end


% CC = bwconncomp(intersection);
% rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
% centers = cat(1, rp.Centroid);

res = struct;
res.windows = {};
res.x = [];
res.y = [];

for cii = 1:min(inf,numel(inDistIndices))
    ci = inDistIndices(cii);
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
%     wmask1 = uint8(bwperim(mask1(cymin:cymax,cxmin:cxmax)));
%     wmask2 = uint8(bwperim(mask2(cymin:cymax,cxmin:cxmax)));
%     
%     window(:,:,1) = window(:,:,1) +255*(wmask1);
%     window(:,:,2) = window(:,:,2) +255*(wmask2);
%     window(:,:,3) = window(:,:,2) +255*(wmask2+wmask1);
   
    currData = data;
    while(isfield(currData.properties,'prev'))
        currData = currData.properties.prev;
        %currmask1 = currData.(props.mask1);
        %currmask2 = currData.(props.mask2);
        
        %border = 5*ones(size(window,1),1);
        %window = cat(2,window, border, currmask1(cymin:cymax,cxmin:cxmax) + 2*currmask2(cymin:cymax,cxmin:cxmax));
        
        currRGB = currData.(props.image);
        border = 255*ones(size(window,1),2,3);
        
        info = [num2str(currData.parameters.time) ]
        position = [0,0];
        wind = currRGB(cymin:cymax,cxmin:cxmax,:);
        %wind = insertText(wind,position,info,'TextColor','white','FontSize',18, 'BoxColor', 'black');
    
        window = cat(2, wind, border, window);
        %window = cat(2,window, border, wind);


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
end

end
