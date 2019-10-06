function [res] = getNN(data, parameters)

props = parseParams(parameters);

static = data.(props.static);
dynamic = data.(props.dynamic);
dinstanceBins = props.dinstanceBins;
repeats = props.repeats;
confidence = props.confidence;

% analyze experimental data
expDistances = getNNdistances(static, dynamic,props);

% generate and analyze CSR
allRndDistances = {};

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
    rndDist = getNNdistances(static, dynamicRandomized, props);
    toc
    allRndDistances{ri} = rndDist;
    disp(['\n'])
end

% extract confidence envelope
figure
subplot(1,3,1)
imshow(single(cat(3,static,dynamic,0*dynamic)));

% version 1: binning

subplot(1,3,2)
hold on;
allRandHists = [];
for ri = 1:repeats
    rndHist = histcounts(allRndDistances{ri} ,dinstanceBins);
    plot(dinstanceBins(1:end-1), rndHist, 'r');
    allRandHists = cat(1,allRandHists ,rndHist);
end
allRandHistsSorted = sort(allRandHists,1)
margin = ceil(confidence*repeats)
plot(dinstanceBins(1:end-1),allRandHistsSorted (margin,:),'k');
plot(dinstanceBins(1:end-1),allRandHistsSorted (end - margin + 1,:),'k');

expHist = histcounts(expDistances ,dinstanceBins);
plot(dinstanceBins(1:end-1), expHist, 'g');


% version 2: cumulative

subplot(1,3,3)

hold on;
for ri = 1:repeats
    dist = allRndDistances{ri};
    [distancesSorted, order] = sort(dist);
    y = (1:numel(distancesSorted))./ numel(distancesSorted);
    y = (1:numel(distancesSorted));
    plot(distancesSorted,y,'r')
end

% envelope: sample curves at intervals


sortedY = [];
maxX = max (cat(2,allRndDistances{:}));
minX = min (cat(2,allRndDistances{:}));
xq = minX:1:maxX;
for ri = 1:repeats
    dist = allRndDistances{ri};
    [distancesSorted, order] = sort(dist);
    x = distancesSorted;
    y = (1:numel(distancesSorted))./ numel(distancesSorted);
    [x,yi] = unique(x)
    y = y(yi);
    yq = interp1(x,y,xq,'linear','extrap');
    sortedY = cat(1,sortedY,yq);
end
sortedSortedY = sort(sortedY,1);
sortedSortedY = max(sortedSortedY,0);
sortedSortedY = min(sortedSortedY,1);

margin = ceil(confidence*repeats)
plot(xq,sortedSortedY(margin,:),'k');
plot(xq,sortedSortedY(end - margin + 1,:),'k');

hold on;
[distancesSorted, order] = sort(expDistances);
y = (1:numel(distancesSorted))./ numel(distancesSorted);
y = (1:numel(distancesSorted));
plot(distancesSorted,y,'g')


res = [];
end

function dynamicRandomized = getDynamicRandomized(static, dynamicEntities, props)

imsize = size(static);
if props.staticOverlap ~= 1
    viableStaticPixels = ~(static);
else
    viableStaticPixels = ones(imsize);
end
viableDynamicPixels = ones(imsize);


%I = zeros(props.imageSize);
I = zeros(imsize);
numDynamicEntities = numel(dynamicEntities.pixels);
successCount = 0;
for di = 1:numDynamicEntities
    tryCount = 0;
    newPixels = [];
    maxTryCount = inf;
    pixels = dynamicEntities.pixels{di};
    while tryCount < maxTryCount
        
        newPixels = randomizePixelsLocationMB(imsize,pixels);
        
        goodLocation = true;
        % check if location is good
        
        if props.staticOverlap == 0
            if (~all(viableStaticPixels(newPixels)))
                goodLocation = false;
            end
        end
        
        if props.staticOverlap == 2
            if (any(viableStaticPixels(newPixels)))
                goodLocation = false;
            end
        end
        
        if props.dynamicOverlap == 0
            if (sum(viableDynamicPixels(newPixels)) ~= numel(newPixels))
                goodLocation = false;
            end
        end
        
        
        if goodLocation
            tryCount = inf;
            if props.dynamicOverlap == 0
                viableDynamicPixels(newPixels) = 0;
            end
            I(newPixels) = di;
            successCount = successCount + 1;
        else
            tryCount = tryCount+1;
        end
    end

end
dynamicRandomized = I;
    
    
if false & props.verbose
    figure;
    oldDynamic = zeros(imsize);
    for di = 1:numDynamicEntities
        oldDynamic(dynamicEntities.pixelsidx{di}) = 1;
    end
	imshow(single(cat(3,static, oldDynamic,I)));
end
end

function newPixels = randomizePixelsLocationMB(imSize,pixels)

maxRows = imSize(1);
maxCols = imSize(2);
curAgg = pixels;

curAggRows = curAgg(:, 2);
curAggCols = curAgg(:, 1);

curAggTopRow = min(curAggRows);
curAggTopCol = min(curAggCols);
maxRowLength = max(curAggRows) - curAggTopRow;
maxColLength = max(curAggCols) - curAggTopCol;

baseAggRows = curAggRows - curAggTopRow + 1;
baseAggCols = curAggCols - curAggTopCol + 1;

curMaxRows = maxRows - maxRowLength;
curMaxCols = maxCols - maxColLength;

randRowInc = randi([0, curMaxRows - 1]);
randColInc = randi([0, curMaxCols - 1]);

newAggRows = baseAggRows + randRowInc;
newAggCols = baseAggCols + randColInc;

% newAggMask = iMask;

newPixels = sub2ind(imSize, newAggRows, newAggCols);
end

function distances = getNNdistances(static, dynamic, props)

%staticEntities = getPropsForSeg(static);

if (islogical(dynamic))
    dynamicEntities = getPropsForSeg(dynamic);
else
    dynamicEntities = struct;
    dynamicEntities.pixelsidx = {};
    maxPIdx = max(dynamic(:));
    
    dynamicEntities.pixelsidx = label2idx(dynamic);
end

numDynamic = numel(dynamicEntities.pixelsidx);

staticDistMap = bwdist(static);
distances = [];
if props.edge
    for pIdx = 1:numDynamic
        cellDistances = staticDistMap(dynamicEntities.pixelsidx{pIdx});
        distances = [distances, min(cellDistances)];
    end
else
    for pIdx = 1:numDynamic
        cellDistances = staticDistMap(dynamicEntities.pixelsidx{pIdx});
        distances = [distances, cellDistances'];
    end
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
    'dinstanceBins_',[0,12*power(2,0:4)], ...
    'dinstanceBins',0:6:200, ...
    'repeats',10, ...
    'confidence', 0.05, ...
    'edge', true, ...
    'staticOverlap', 0, ...
    'dynamicOverlap', 0, ...
    'verbose', true ...
    )

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'static'))
        props.static = v{i+1};
    elseif (strcmp(v{i}, 'dynamic'))
        props.dynamic = v{i+1};
    elseif (strcmp(v{i}, 'dinstanceBins'))
        props.dinstanceBins = v{i+1};
    elseif (strcmp(v{i}, 'repeats'))
        props.repeats = v{i+1};
    elseif (strcmp(v{i}, 'confidence'))
        props.confidence = v{i+1};
    elseif (strcmp(v{i}, 'edge'))
        props.edge = v{i+1};
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