function dynamicRandomized = getDynamicRandomized(static, dynamicEntities, props)


if isfield(props, 'randomization') && strcmp(props.randomization, 'daime')
    if props.staticOverlap
        available = 1:numel(static);
    else
        available = find(static==0);
    end
    idx_in_available = 1:numel(available);
    numDynamicEntitiesPixels = numel(cat(1,dynamicEntities.pixelsidx{:}));
    idx_to_mark = randperm(numel(available), numDynamicEntitiesPixels);
    
    I = zeros(size(static));
    I(available(idx_to_mark)) = 1;
    
    dynamicRandomized = I;
else
    
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
    
    randomOrder = randperm(numDynamicEntities);
    for di = 1:numDynamicEntities
        tryCount = 0;
        maxTryCount = 1000;
        pixels = dynamicEntities.pixels{randomOrder(di)};
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
end

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

