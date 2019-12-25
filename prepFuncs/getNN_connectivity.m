function [res] = getNN_connectivity(data, parameters)

props = parseParams(parameters);

static = data.(props.static);
dynamic = data.(props.dynamic);

pixelSize = data.properties.pixelSize;
repeats = props.repeats;

connDist = props.connDist / pixelSize;

% delete: moved to visualization
% distanceBins = props.distanceBins;
% confidence = props.confidence;






% analyze experimental data

[staticDistMap, staticNghMap]  = bwdist(static);

%props.verbose = true
expDistances = getNNdistances(staticDistMap , dynamic,props);
expConn = getConnDist(staticDistMap, staticNghMap, dynamic, connDist, props);
%expConn = [];
%props.verbose = false
% generate and analyze CSR
allRndDistances = {};
allRndConnDist = {}
allRndDD = [];

% doing once, saving time
dynamicEntities = getPropsForSeg(dynamic);
staticEntities = getPropsForSeg(static);

% does the thing
for ri = 1:repeats
    disp(['randomized ' , num2str(ri)])
    tic
    if (strcmp(props.randomize, 'dyn'))
        dynamicRandomized = getDynamicRandomized(static, dynamicEntities, props);
    else
        staticRandomized = getDynamicRandomized(static, staticEntities, props);
    end
    toc
    disp(['NN ' , num2str(ri)])
    
    tic
    rndDist = 0;
    %rndDist = getNNdistances(staticDistMap, dynamicRandomized, props);
    
    
    toc
    disp(['DD ' , num2str(ri)])
    tic
    if (strcmp(props.randomize, 'dyn'))
        rndConn = getConnDist(staticDistMap, staticNghMap, dynamicRandomized, connDist, props);
    else
        [staticDistMap, staticNghMap]  = bwdist(staticRandomized);
        rndConn = getConnDist(staticDistMap, staticNghMap, dynamic, connDist, props);
    end
    
    
    toc
    allRndDistances{ri} = rndDist;
    allRndConnDist{ri} = rndConn;
    %allRndDD = cat(1,allRndDD,rndDD);
    
    disp(['\n'])
    
    
end

res = struct;
res.expDistances = expDistances * pixelSize;
res.expConn = expConn;
for ri = 1:repeats
    allRndDistances{ri} = allRndDistances{ri}*pixelSize;
end
res.allRndDistances = allRndDistances;
res.allRndConnDist = allRndConnDist;

end

% function dynamicRandomized = getDynamicRandomized(static, dynamicEntities, props)
%
% imsize = size(static);
% if props.staticOverlap ~= 1
%     viableStaticPixels = ~(static);
% else
%     viableStaticPixels = ones(imsize);
% end
% viableDynamicPixels = ones(imsize);
%
%
% %I = zeros(props.imageSize);
% I = zeros(imsize);
% numDynamicEntities = numel(dynamicEntities.pixels);
% successCount = 0;
%
% randomOrder = randperm(numDynamicEntities);
% for di = 1:numDynamicEntities
%     tryCount = 0;
%     maxTryCount = inf;
%     pixels = dynamicEntities.pixels{randomOrder(di)};
%     while tryCount < maxTryCount
%
%         newPixels = randomizePixelsLocationMB(imsize,pixels);
%
%         goodLocation = true;
%         % check if location is good
%
%         if props.staticOverlap == 0
%             if (~all(viableStaticPixels(newPixels)))
%                 goodLocation = false;
%             end
%         end
%
%         if props.staticOverlap == 2
%             if (any(viableStaticPixels(newPixels)))
%                 goodLocation = false;
%             end
%         end
%
%         if props.dynamicOverlap == 0
%             if (sum(viableDynamicPixels(newPixels)) ~= numel(newPixels))
%                 goodLocation = false;
%             end
%         end
%
%
%         if goodLocation
%             tryCount = inf;
%             if props.dynamicOverlap == 0
%                 viableDynamicPixels(newPixels) = 0;
%             end
%             I(newPixels) = di;
%             successCount = successCount + 1;
%         else
%             tryCount = tryCount+1;
%         end
%     end
%
% end
% dynamicRandomized = I;
%
%
% if false & props.verbose
%     figure;
%     oldDynamic = zeros(imsize);
%     for di = 1:numDynamicEntities
%         oldDynamic(dynamicEntities.pixelsidx{di}) = 1;
%     end
% 	imshow(single(cat(3,static, oldDynamic,I)));
% end
% end
%
% function newPixels = randomizePixelsLocationMB(imSize,pixels)
%
% maxRows = imSize(1);
% maxCols = imSize(2);
% curAgg = pixels;
%
% curAggRows = curAgg(:, 2);
% curAggCols = curAgg(:, 1);
%
% curAggTopRow = min(curAggRows);
% curAggTopCol = min(curAggCols);
% maxRowLength = max(curAggRows) - curAggTopRow;
% maxColLength = max(curAggCols) - curAggTopCol;
%
% baseAggRows = curAggRows - curAggTopRow + 1;
% baseAggCols = curAggCols - curAggTopCol + 1;
%
% curMaxRows = maxRows - maxRowLength;
% curMaxCols = maxCols - maxColLength;
%
% randRowInc = randi([0, curMaxRows - 1]);
% randColInc = randi([0, curMaxCols - 1]);
%
% newAggRows = baseAggRows + randRowInc;
% newAggCols = baseAggCols + randColInc;
%
% % newAggMask = iMask;
%
% newPixels = sub2ind(imSize, newAggRows, newAggCols);
% end
% %
% function distanceDensity = getNNDD(staticDistMap, dynamic, props)
%
% if (islogical(dynamic))
%     dynamicEntities = getPropsForSeg(dynamic);
% else
%     dynamicEntities = struct;
%     dynamicEntities.pixelsidx = {};
%     maxPIdx = max(dynamic(:));
%
%     dynamicEntities.pixelsidx = label2idx(dynamic);
% end
%
% dynamicMask = dynamic > 0;
%
% dynDistHist = histcounts(staticDistMap(dynamicMask) ,props.distanceBins);
% totDistHist = histcounts(staticDistMap(:) ,props.distanceBins);
%
%
% distanceDensity = struct;
% distanceDensity.dyn = dynDistHist;
% distanceDensity.tot = totDistHist;
% distanceDensity.bins = props.distanceBins(1:end-1);
%
% end

function connDist = getConnDist(staticDistMap, staticNghMap, dynamic, connDist, props);
if (islogical(dynamic))
    dynamicEntities = getPropsForSeg(dynamic);
else
    dynamicEntities = struct;
    dynamicEntities.pixelsidx = {};
    maxPIdx = max(dynamic(:));
    
    dynamicEntities.pixelsidx = label2idx(dynamic);
end

static = (staticDistMap == 0);% :)
L = bwlabel(static);
numDynamic = numel(dynamicEntities.pixelsidx);


%staticDistMap = bwdist(staticDistMap);
conn = [];

if props.verbose
    
end

if props.verbose
    vimage = zeros(size(staticNghMap));
end

for pIdx = 1:numDynamic
    cellDistances = staticDistMap(dynamicEntities.pixelsidx{pIdx});
    
    [minDist, min_cellIdx] = min(cellDistances);
    min_bigIdx = dynamicEntities.pixelsidx{pIdx}(min_cellIdx);
    label = L(staticNghMap(min_bigIdx));
    if (minDist<connDist)
        if strcmpi(props.mode, 'pixels') 
            % count all pixels in cells
            conn = [conn, repmat(label,1,numel(cellDistances))];
        else
            % count once per cell
            conn = [conn, label];
        end
        if props.verbose
            indices = find(L == label);
            if strcmpi(props.mode, 'pixels') 
                vimage(indices) = vimage(indices)+numel(cellDistances);
            else
                vimage(indices) = vimage(indices)+1;
            end
        end
    end
    
end

connDist = histcounts(conn,1:max(conn));
connDist = sort(connDist,'descend');
connDist = connDist(connDist>0);


if props.verbose
    figure
    
    
    bg = bwperim(staticDistMap == 0);
    %bg = bg + vimage;
    cmap = (hsv(200));
    cmap = cmap(1:(end*0.75),:);
    cmap(1,:) = [0 0 0];
    indimage = 1 + ceil((150*(vimage)) / max(vimage(:) ) );
    %indimage = vimage;
    %cmap(1,:) = [0,0,0];
    rgbImage = ind2rgb(indimage, cmap);
    
    R = rgbImage(:,:,1);
    G = rgbImage(:,:,2);
    B = rgbImage(:,:,3);
    
    R(bg) = 1;
    G(bg) = 1;
    B(bg) = 1;
    
    R(dynamic > 0) = 1;
    G(dynamic > 0) = 1;
    B(dynamic > 0) = 1;
    
    rgbImage = cat(3,R,G,B);
    imshow(rgbImage)
    colormap(cmap)
    colorbar;
    caxis([0,max(vimage(:))])
    
end



end

function distances = getNNdistances(staticDistMap, dynamic, props)

if (islogical(dynamic))
    dynamicEntities = getPropsForSeg(dynamic);
else
    dynamicEntities = struct;
    dynamicEntities.pixelsidx = {};
    maxPIdx = max(dynamic(:));
    
    dynamicEntities.pixelsidx = label2idx(dynamic);
end

numDynamic = numel(dynamicEntities.pixelsidx);


%staticDistMap = bwdist(staticDistMap);
distances = [];

if props.verbose
    
end

if props.verbose
    vimage = nan(size(staticDistMap));
end

if true || strcmp(props.mode, 'edge')
    for pIdx = 1:numDynamic
        cellDistances = staticDistMap(dynamicEntities.pixelsidx{pIdx});
        if props.verbose
            vimage(dynamicEntities.pixelsidx{pIdx}) = min(cellDistances);
        end
        distances = [distances, min(cellDistances)];
    end
elseif strcmp(props.mode, 'edgeW')
    for pIdx = 1:numDynamic
        cellDistances = staticDistMap(dynamicEntities.pixelsidx{pIdx});
        if props.verbose
            vimage(dynamicEntities.pixelsidx{pIdx}) = min(cellDistances);
        end
        temp = repmat(min(cellDistances),1,numel(cellDistances));
        distances = [distances, temp];
    end
else
    for pIdx = 1:numDynamic
        cellDistances = staticDistMap(dynamicEntities.pixelsidx{pIdx});
        if props.verbose
            vimage(dynamicEntities.pixelsidx{pIdx}) = cellDistances;
        end
        
        distances = [distances, cellDistances'];
    end
end

if props.verbose
    figure
    
    vimage = (vimage*0.16);
    cmap = (hsv(200));
    cmap = cmap(1:(end*0.75),:);
    indimage = 1 + ceil((100*(vimage)) / max(vimage(:) ) );
    %cmap(1,:) = [0,0,0];
    rgbImage = ind2rgb(indimage, cmap);
    
    R = rgbImage(:,:,1);
    G = rgbImage(:,:,2);
    B = rgbImage(:,:,3);
    
    R(isnan(vimage)) = 0;
    G(isnan(vimage)) = 0;
    B(isnan(vimage)) = 0;
    
    R((staticDistMap == 0) & (~dynamic)) = 1;
    G((staticDistMap == 0) & (~dynamic)) = 1;
    B((staticDistMap == 0) & (~dynamic)) = 1;
    
    rgbImage = cat(3,R,G,B);
    imshow(rgbImage)
    colormap(cmap)
    colorbar;
    caxis([0,max(vimage(:))])
end


end

function props = getPropsForSeg(im)

CC = bwconncomp(im);
rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
centers = cat(1, rp.Centroid);
pixels = cell(numel(rp),1);
pixelsidx = cell(numel(rp),1);
for ii = 1:numel(rp)
    pixels{ii} = rp(ii).PixelList;
    pixelsidx{ii} = rp(ii).PixelIdxList;
end
areas = cat(1, rp.Area);

% from array of structs to struct of arrays...

props = struct;
props.centers = centers;
props.areas = areas;
props.pixels = pixels;
props.pixelsidx = pixelsidx;

end

function props = parseParams(v)
% default:
props = struct(...
    'static','BF',...
    'dynamic','GFP',...
    'distanceBins_',[0,12*power(2,0:4)], ...
    'distanceBins',0:1:1200, ...
    'repeats',10, ...
    'confidence__', 0.05, ...
    'mode', 'notpixels', ...
    'connDist', 2, ...
    'staticOverlap', 0, ...
    'dynamicOverlap', 0, ...
    'randomize', 'dyn',...
    'verbose', 0 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'static'))
        props.static = v{i+1};
    elseif (strcmp(v{i}, 'dynamic'))
        props.dynamic = v{i+1};
    elseif (strcmp(v{i}, 'distanceBins'))
        props.distanceBins = v{i+1};
    elseif (strcmp(v{i}, 'repeats'))
        props.repeats = v{i+1};
    elseif (strcmp(v{i}, 'confidence'))
        props.confidence = v{i+1};
    elseif (strcmp(v{i}, 'mode'))
        props.mode = v{i+1};
    elseif (strcmp(v{i}, 'connDist'))
        props.connDist = v{i+1};
    elseif (strcmp(v{i}, 'staticOverlap'))
        props.staticOverlap = v{i+1};
    elseif (strcmp(v{i}, 'dynamicOverlap'))
        props.dynamicOverlap = v{i+1};
    elseif (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};
    elseif (strcmp(v{i}, 'randomize'))
        props.randomize = v{i+1};
    end
end

end