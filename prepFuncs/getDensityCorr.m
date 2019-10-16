function [allresults] = getDensityCorr(data, parameters)

props = parseParams(parameters);

pixelSize = data.properties.pixelSize;
radius = props.radius ./ pixelSize;
allres = [];
for ri = 1:numel(radius)
   
    res = struct;
    res.radius = radius(ri);
    res.res = getDensityCorrAux(data, parameters, res.radius);
    allres = cat(1,allres,res);
end

allresults = struct;
allresults.pool = allres

end

function [res] = getDensityCorrAux(data, parameters, radius)

props = parseParams(parameters);

static = data.(props.static);
dynamic = data.(props.dynamic);

repeats = props.repeats;


% delete: moved to visualization
% distanceBins = props.distanceBins;
% confidence = props.confidence;

% analyze experimental data


disk = getDisk(radius);

staticDensityMap = conv2(static, disk,'same');
boundaryFactor = conv2(ones(size(static)), disk, 'same');

staticDensityMap = staticDensityMap ./ boundaryFactor;

%props.verbose = true
expDensities = getDensities(staticDensityMap , dynamic,props);

%props.verbose = false
% generate and analyze CSR
allRndDensities = {};

% doing once, saving time
dynamicEntities = getPropsForSeg(dynamic);

% does the thing
for ri = 1:repeats
    disp(['randomized ' , num2str(ri)])
    tic 
    dynamicRandomized = getDynamicRandomized(static, dynamicEntities, props);
    toc
    disp(['NN ' , num2str(ri)])
    tic 
    rndDist = getDensities(staticDensityMap, dynamicRandomized, props);
    toc
    allRndDensities{ri} = rndDist;
    disp([''])
end

res = struct;
res.expDensities = expDensities;

for ri = 1:repeats
    allRndDensities{ri} = allRndDensities{ri};
end
res.allRndDensities = allRndDensities;

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
% 

function densities = getDensities(staticDensityMap, dynamic, props)


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
densities = [];

if props.verbose
    
end

if props.verbose
    vimage = nan(size(staticDensityMap));
end

if strcmp(props.mode, 'edge')
    for pIdx = 1:numDynamic
        environmentDensities = staticDensityMap(dynamicEntities.pixelsidx{pIdx});
        if props.verbose
            vimage(dynamicEntities.pixelsidx{pIdx}) = max(environmentDensities);
        end
        densities = [densities, max(environmentDensities)];
    end
else
    for pIdx = 1:numDynamic
        environmentDensities = staticDensityMap(dynamicEntities.pixelsidx{pIdx});
        if props.verbose
            vimage(dynamicEntities.pixelsidx{pIdx}) = environmentDensities;
        end

        densities = [densities, environmentDensities'];
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

%    R((staticMap == 1) & (~dynamic)) = 1;
%    G((staticMap == 1) & (~dynamic)) = 1;
%    B((staticMap == 1) & (~dynamic)) = 1;
    
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
    'radius', 5,...
    'repeats',10, ...
    'confidence__', 0.05, ...
    'mode', 'edge', ...
    'staticOverlap', 0, ...
    'dynamicOverlap', 0, ...
    'verbose', 0 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'static'))
        props.static = v{i+1};
    elseif (strcmp(v{i}, 'dynamic'))
        props.dynamic = v{i+1};
    elseif (strcmp(v{i}, 'radius'))
        props.radius = v{i+1};
    elseif (strcmp(v{i}, 'repeats'))
        props.repeats = v{i+1};
    elseif (strcmp(v{i}, 'confidence'))
        props.confidence = v{i+1};
    elseif (strcmp(v{i}, 'mode'))
        props.mode = v{i+1};
    elseif (strcmp(v{i}, 'staticOverlap'))
        props.staticOverlap = v{i+1};
    elseif (strcmp(v{i}, 'dynamicOverlap'))
        props.dynamicOverlap = v{i+1};
    elseif (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};
        
    end
end

end

function AvCvD = getAttachVsCountDistProject4( ...
    imBF_BW, imGFP_BW, ...
    distBins, accumDist, conf_interv, BF_nonviable, ...
    removeGFPFoundOnBF, allowSmallOverlapPerc, ...
    repeats, ...
    edgeCloseness, ...
    aggregateRandomization, aggregateRandomizationNoOverlap, ...
    verbose, verboseFigs, verboseOpts, imBF_origImagePath, imGFP_origImagePath, numOfBinsVisualize, fluorescenceIntensityFactor, getCalibr, ...
    removedRegionsMask, normalizePerWellSize...
    )

end