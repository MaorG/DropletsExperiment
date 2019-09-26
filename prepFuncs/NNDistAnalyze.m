%function AvCvD = NNDistAnalyze(imBF_BW, imGFP_BW, distBins, accumDist, conf_interv, BF_nonviable, removeGFPFoundOnBF, allowMaxOverlapPerc, repeats, edgeCloseness, aggregateRandomization, aggregateRandomizationNoSelfOverlap, verbose, verboseFigs, verboseOpts, imBF_origImagePath, imGFP_origImagePath, numOfBinsVisualize, fluorescenceIntensityFactor, getCalibr, removedRegionsMask, normalizePerWellSize, isPerPixel, NNcumulative, randomizationBFOverlap)

function res = NNDistAnalyze(data,parameters)
% by Maor
% Statistical Analysis of BW images of GFP in relation to corresponding BF image.
% checks if GFP cell attachment is close to BF microbiota compared to randomized
% scatterings of GFP cells

% INPUT:
% imBF_BW - brightfield segmented BW image (or RFP image; or any image of
% non-target microbiota to check GFP distances in relation to)
% imGFP_BW - target bacteria segmented BW image
% distBins - bin edges array for relevant bacteria distances that signifies
% closeness, e.g. [0 24]
% accumDist - set to true for accumulative distances
% conf_interv - confidence interval value, 0.95 by convention
% BF_nonviable - true to exclude BF areas from viable pixels for GFP randomized
% projections (used when data includes only one Z plane, hence most GFP cells won't
% be found there), but sometimes even with one Z we still wouldn't turn
% this on if some GFP cells are still found on top of BF aggregates
% removeGFPFoundOnBF -  set to true to remove all GFP cells that overlap with microbiota before analysis
% edgeCloseness - true to measure distances from edges of GFP to BF rather
% than centers of GFP to BF (uses closest edge to nearest BF)
% aggregateRandomization - set to true to change the randomization
% algorithm to randomize the actual full cells rather than virtual centers
% (relevant only when measures edge-to-edge - wen edgeCloseness == true)
% verbose - true for visual view of results
% verboseFigs - figure 1 is BW, figure 2 is original; example: [1 2]
% verboseOpts - more properties for verbose - 1 for encircling of GFP (star for in-distance [discard with 8], round for out-distance [discard with 7]),
% 2 for marking centers of GFP cells and view distance from near BF near each
% GFP center as well as vieweing area of that GFP (use 6 to discard the area), 3 for bin encircling visualization,
% 4 for GFP emphasis by original GFP image, 5 for showing micrometers
% instead of pixels (requires 2).
% use 9 for showing areas of BF
% use 10 to avoid putting borders on segmented BF and GFP
% example: [1 2 3 4]

% OUTPUT
% AvCvD - struct with statistical measures

% example: AvCvD = getAttachVsCountDistProject4(im_BF3, im_GFP2, [0 24], true, 0.95, true, true)

%params = parseInput(varargin);



imageSize = size(imBF_BW);

countBins = [1, inf];
% note - cumulative (i.e. up to dist or in range) ?

% create bitmap for each cluster count bin

countDistHist = [];

relativeCountDistHist = [];
expectedCountsDistHist = [];
topConfCountsDistHist = [];
botConfCountsDistHist = [];
avgConfCountsDistHist = [];
topConfCountsDistHistAnalytic = [];
botConfCountsDistHistAnalytic = [];

% if (numel(countBins) == 2) && (numel(distBins) == 2)
%     verbose = true;
%     figure;
% end

GFPprops = getPropsForSeg(imGFP_BW);
BFprops = getPropsForSeg(imBF_BW);

numGFP = numel(GFPprops.pixels);

if (removeGFPFoundOnBF)
    removeInds = zeros(numGFP, 1);
    removeInc = 0;
    imBF_BW2 = imfill(imBF_BW,'holes'); % fill holes in BF aggregates to check for overlap (needed because of dilation and subtraction of GFP from BF in the segmentation process)
    imGFP_BWold = imGFP_BW;
    imBF_BWold = imBF_BW;
    for pIdx = 1:numGFP
        curPixels = GFPprops.pixelsidx{pIdx};
        [a1, b1] = ind2sub(size(imGFP_BW), curPixels);
        if any(all([a1, b1] == [1235 4762],2))
            disp(pIdx);
        end
        overlappingPxls = sum(imBF_BW2(curPixels));
        if (overlappingPxls && (isempty(allowMaxOverlapPerc) || overlappingPxls/GFPprops.areas(pIdx)*100 >= allowMaxOverlapPerc)) % if there is any overlapping pixels and in case allowed percentage specified - less or equal to that percentage overlap
            removeInc = removeInc + 1;
            removeInds(removeInc) = pIdx;
            imGFP_BW(curPixels) = 0;
            a{removeInc} = a1;
            b{removeInc} = b1;
        end % note: in most cases there will be a full overlap due to the segmentation process which somewhat prevents partial overlap (although I did see a minor few cells which circumvented that) because of the dilation and then subtraction of GFP from BF, so eventually the fill holes will not include the partially protruding cells
        % to remove only cells with full overlap (inside the BF) - set allowMaxOverlapPerc to 100
        % to not allow any overlap, set allowMaxOverlapPerc to []
    end
    if (removeInc < numGFP)
        removeInc = removeInc + 1;
        removeInds(removeInc:end) = [];
    end
    pfields = fieldnames(GFPprops);
    for i = 1 : numel(pfields)
        GFPprops.(pfields{i})(removeInds, :) = [];
    end 
    numGFP = numel(GFPprops.pixels);
end


for countIdx = 1:(numel(countBins) - 1)

    blank = imBF_BW; 
    
    % create dist map
    
    clusterDilation = 0;
    se = strel('disk',clusterDilation);
    blank2 = imdilate(blank, se);
    distMap = bwdist(blank2);
    
    %distMap(distMap == 0) = nan;
    

    % (compare to rand or normalize by total aera of bin of distances? or both, for error margin around 1?)

    if (edgeCloseness)
        % get values of points on distmap - the minimal distances of objects
        dists = [];
        for pIdx = 1:numGFP
            cellDistances = distMap(GFPprops.pixelsidx{pIdx});
            if (isPerPixel)
                dists = [dists, (cellDistances)'];
            else
                dists = [dists, min(cellDistances)];
            end
        end
    else
        % get values of points on dist map
        dists = [];
        for pIdx = 1:numGFP
            center = GFPprops.centers(pIdx,:);
            cx = ceil(center(1));
            cx = min(max(1,cx),imageSize(2));
            cy = ceil(center(2));
            cy = min(max(1,cy),imageSize(1));
            dists = [dists, distMap(cy,cx)];
        end
    end

    
    % hist by dist bins - counting attachments
    distHist = histcounts(dists,distBins);
    if (accumDist)
        distHist = cumsum(distHist);
    end
    
    
    
    % hist by dist bins - # of attachments relative to random, i.e. total
    % area of the diatance
    
    % totalAreaAtDist = histcounts(distMap(:), distBins) ./ sum(~isnan(distMap(:)));

    %     viablePixels = find(~(data.dpI));
    %     totalAreaAtDist = histcounts(distMap(viablePixels), distBins)./sum(~(data.dpI(:)));
    
    
    if (BF_nonviable)
        viablePixels = find(imBF_BW == 0);
        totalAreaAtDist = histcounts(distMap(viablePixels), distBins)./numel(viablePixels);
    else
        totalAreaAtDist = histcounts(distMap(:), distBins)./(size(distMap,1)*size(distMap,2));
    end
    
    
    
    if (accumDist)
        totalAreaAtDist = cumsum(totalAreaAtDist);
    end
    
    expectedAttachmentsAtDist = (numGFP) * totalAreaAtDist;
    expectedCountsDistHist = [expectedCountsDistHist; expectedAttachmentsAtDist];
    


    
    topConfDistHistAnalytic = totalAreaAtDist + sqrt(totalAreaAtDist ./ (numGFP));
    botConfDistHistAnalytic = totalAreaAtDist - sqrt(totalAreaAtDist ./ (numGFP));

    topConfCountsDistHistAnalytic = [topConfCountsDistHistAnalytic; topConfDistHistAnalytic];
    botConfCountsDistHistAnalytic = [botConfCountsDistHistAnalytic; botConfDistHistAnalytic];
    
    relDistHist = distHist ./ expectedAttachmentsAtDist;
    
    % store dist hist
    
    countDistHist = [countDistHist ; distHist];
    relativeCountDistHist = [relativeCountDistHist; relDistHist];
    
    
    
    
    % get list of viable pixels
    if (BF_nonviable)
        viablePixelsBF = imBF_BW == 0;
    else
        viablePixelsBF = ones(size(distMap, 1), size(distMap, 2));
    end
    
    if (~isempty(removedRegionsMask))
        viablePixelsFromMask = ~removedRegionsMask;
    else
        viablePixelsFromMask = ones(size(distMap, 1), size(distMap, 2));
    end
    

    viablePixels = find(viablePixelsBF & viablePixelsFromMask);
    
    viablePixelsBF = find(viablePixelsBF);
    viablePixelsFromMask = find(viablePixelsFromMask);

    % for normalization of the counts (divide the counts you later get
    % by this number to get the normalized value per the total area)
    if (normalizePerWellSize)
        totExtrapolateFactor = numel(viablePixelsFromMask(:)) / normalizePerWellSize;
    else
        totExtrapolateFactor = numel(viablePixelsFromMask(:)) / numel(viablePixelsBF);
    end    
    
    % the following origImageGFP, origImageBF reads are used for
    % debugging purposes when randomizeAggregatesDists is run with
    % these parameters
    
    origImageGFP = imread(imGFP_origImagePath);
    if (cutImagePortion)
        origImageGFP = origImageGFP(cutRows, cutCols);
    end
    origImageBF = imread(imBF_origImagePath);
    if (cutImagePortion)
        origImageBF = origImageBF(cutRows, cutCols);
    end
    if (~isempty(removedRegionsMask))
        origImageBF(getBWPerimeter(removedRegionsMask, 2, 20)) = 0;
    end

    % random repetitions
    if (isempty(repeats))
        repeats = 1000; % default if not specified
    end
    allRndDistHist = [];
    allRndDists = [];
    
    % for debugging: 
    % aggregateRandomization = false;
    % tic
    
    allRows = []; % for scatter visualization of viable pixels (debugging)
    allCols = cell(0); % ...
    % rMaskTot = zeros(size(imGFP_BW)); % for debugging - checking randomization mask
    for repeat = 1:repeats
        
        % 1. get "A" list of numel(GFPprops.areas) pixels only from viablePixels
        % 2. get distances of the "A" pixels 
        
        if (aggregateRandomization)
           % [rndDists, rMask] = randomizeAggregatesDists(distMap,
           % for debugging: % GFPprops.pixels, viablePixels, aggregateRandomizationNoSelfOverlap, distBins, imBF_BW, origImageBF, origImageGFP, isPerPixel, randomizationBFOverlap); 
           rndDists = randomizeAggregatesDists(distMap, GFPprops.pixels, viablePixels, aggregateRandomizationNoSelfOverlap, distBins, imBF_BW, origImageBF, origImageGFP, isPerPixel, randomizationBFOverlap);
           % rMaskTot = rMaskTot | getBWPerimeter(rMask, 1, 1); % for debugging - checking randomization mask
        else
            
            randomIdx = randi([1,numel(viablePixels)],numGFP, 1);
            
            
            randomPixels = viablePixels(randomIdx);
            
%             [rows ,cols] = ind2sub(size(distMap), randomPixels); % for scatter visualization of viable pixels (debugging)
%             allRows = [allRows; rows]; % ...
%             allCols = [allCols; cols]; % ...
            rndDists = distMap(randomPixels);
        end
        
        % allRndDists - used for NNcumulative - storing this data matrix for the output
        % of this function to have all the randomized iterations distances
        if (NNcumulative)
            allRndDists{repeat} = rndDists;
        end
        
        rndDistHist = histcounts(rndDists,distBins);
        
%         % for debugging
%         if (rndDistHist(3) == 0)
%             disp(0);
%         end
        
        if (accumDist)
            rndDistHist = cumsum(rndDistHist);
        end
        allRndDistHist = [allRndDistHist ; rndDistHist];
    end
    %toc
    % 2 separate hypotheses so it's one sided for each one (one question is
    % whether the GFP are in the range (e.g. BF range of 0-24, same as close BF), the other is
    % wheteher the GFP are outside the range (for 0-24, same as further from the BF) [the hypotheses
    % are separated because they are probably dominated by two separate
    % mechanisms]). the 2 hypotheses statistical significance will be named
    % top for close (because more are in the range) and bottom for far
    % (because there are less in the range)
    stat_signif = 1 - conf_interv;
    diff = repeats * stat_signif;
    bot_conf = fix(diff);
    if (bot_conf == 0)
        bot_conf = 1;
    end
    top_conf = fix(repeats - diff + 1);
    sortedRndDistHist = sort(allRndDistHist,1);
    topConfDistHist = sortedRndDistHist(top_conf,:);
    botConfDistHist = sortedRndDistHist(bot_conf,:);
    avgConfDistHist = mean(sortedRndDistHist, 1);
    
    topConfCountsDistHist = [topConfCountsDistHist ; topConfDistHist];
    botConfCountsDistHist = [botConfCountsDistHist ; botConfDistHist];
    avgConfCountsDistHist = [avgConfCountsDistHist ; avgConfDistHist];
    
    verbose = false;
    verboseOpts = [3 4 1];
    
    if verbose

        R = 0.8 * imBF_BW;
        G = 0.8 * imGFP_BW;
        B = 0.75 * (distMap >= distBins(1) & distMap < distBins(2)) * 255;
        
        
        if (~isempty(imBF_origImagePath))
            % green circle around GFP cells
            widthAroundGFP = 2; % 14
            if (any(verboseOpts == 10))
                G2 = uint16(zeros(size(distMap)));
            else                
                G2 = im2uint16(mat2gray(getBWPerimeter(imGFP_BW, 3, widthAroundGFP)));
            end
            
            % red circle around distance bins
            numOfBins = numel(distBins) - 1;
            if (numOfBinsVisualize > numOfBins)
                numOfBinsVisualize = numOfBins;
            end
            binsEncircling = zeros(size(distMap));
            R2 = uint16(binsEncircling);
            for b = 1 : numOfBinsVisualize 
                binEncircling = getBWPerimeter(distMap >= distBins(1) & distMap < distBins(b+1), 1, 2);
                binsEncircling = binsEncircling | binEncircling;
            end
            if (any(verboseOpts == 3))
               R2 = R2 + im2uint16(mat2gray(binsEncircling));
            end
            origImageGFP = imread(imGFP_origImagePath);
            if (cutImagePortion)
                origImageGFP = origImageGFP(cutRows, cutCols);
            end
            if (any(verboseOpts == 4))
               R2 = R2 + im2uint16(mat2gray(origImageGFP))*fluorescenceIntensityFactor;
            end
            origImageBF = imread(imBF_origImagePath);
            if (cutImagePortion)
                origImageBF = origImageBF(cutRows, cutCols);
            end
            origImageBF2 = origImageBF;
            if (all(verboseOpts ~= 10))
                origImageBF2(getBWPerimeter(imBF_BW, 3, 2)) = intmax('uint16');
            end
            if (~isempty(removedRegionsMask))
                origImageBF(getBWPerimeter(removedRegionsMask, 2, 20)) = 0;
                origImageBF2(getBWPerimeter(removedRegionsMask, 2, 20)) = 0;
            end
            origImage = cat(3, R2 + origImageBF2, G2 + origImageBF2, origImageBF2);
            
            totVerboseFigs = 2;
             
%             origImageBF = imread(imBF_origImagePath);
%             origImageGFP = imread(imGFP_origImagePath) * 40;
%             origImageGFP(~imGFP_BW) = 0;
%             origImage = cat(3, origImageGFP + origImageBF, origImageBF, origImageBF);
        else
             totVerboseFigs = 1;
        end
        
        for f = 1 : totVerboseFigs
            if (~any(verboseFigs == f))
                continue;
            end
            figure;
            if (f == 2)
                imshow(origImage);
            else
                imshow(cat(3,R,G,B));
            end
            
            if (any(verboseOpts == 1))
                hold on;
                indists = dists >= distBins(1) & dists < distBins(numOfBinsVisualize+0);
                outdists = dists < distBins(1) | dists >= distBins(numOfBinsVisualize+0);
                if (~any(verboseOpts == 7)) 
                    plot(GFPprops.centers(outdists,1),GFPprops.centers(outdists,2), ...
                    'o', 'MarkerSize',20, 'LineWidth', 1,...
                    'MarkerEdgeColor',[0,0,0.5],...
                    'MarkerFaceColor','none');
                end
                %         plot(data.Gclusters.centers(outdists,1),data.Gclusters.centers(outdists,2), ...
                %             'o', 'MarkerSize',20, 'LineWidth', 1,...
                %             'MarkerEdgeColor',[1,0,0],...
                %             'MarkerFaceColor','none')
                if (~any(verboseOpts == 8)) 
                    plot(GFPprops.centers(indists,1),GFPprops.centers(indists,2),...
                    'h', 'MarkerSize',20, 'LineWidth', 1,...
                    'MarkerEdgeColor',[0,1,0],...
                    'MarkerFaceColor','none')
                end
                %         plot(data.Gclusters.centers(indists,1),data.Gclusters.centers(indists,2),...
                %             'o', 'MarkerSize',20, 'LineWidth', 1,...
                %             'MarkerEdgeColor',[0,0,1],...
                %             'MarkerFaceColor','none')
            end
            
            if (any(verboseOpts == 2))
                % mark centers of GFP cells and view distance from near BF near each GFP center
                for pIdx = 1:numel(GFPprops.pixels)
                    center = GFPprops.centers(pIdx,:);
                    cx = ceil(center(1));
                    cx = min(max(1,cx),imageSize(2));
                    cy = ceil(center(2));
                    cy = min(max(1,cy),imageSize(1));
                    plot(cx, cy, 'r*');
                    % distMeasure = distMap(cy, cx);
                    distMeasure = dists(pIdx);
                    appendText = [];
                    if (any(verboseOpts == 5))
                        distMeasure = distMeasure * getCalibr;
                        appendText = '\mum';
                    end 
                    text(cx + 5, cy + 5, [num2str(distMeasure), appendText], 'Color', 'w', 'FontSize', 8);
                    if (~any(verboseOpts == 6)) 
                        text(cx + 5, cy + 15, num2str(GFPprops.areas(pIdx)), 'Color', 'w', 'FontSize', 8);
                    end
                end
                
            end
            
            if (any(verboseOpts == 9))
                % shows areas for BF
                for pIdx = 1:numel(BFprops.pixels)
                    center = BFprops.centers(pIdx,:);
                    cx = ceil(center(1));
                    cx = min(max(1,cx),imageSize(2));
                    cy = ceil(center(2));
                    cy = min(max(1,cy),imageSize(1));
                    text(cx + 5, cy + 15, num2str(BFprops.areas(pIdx)), 'Color', 'w', 'FontSize', 8);
                end
            end
            
            if (any(verboseOpts == 1))
                text(10,100,['totalAttach: ', num2str(numel(indists))],'Color','y','FontSize',10);
                text(10,250,['in dist: ', num2str(sum(indists))],'Color','y','FontSize',10);
                text(10,400,['relevant area: ', num2str(totalAreaAtDist)],'Color','y','FontSize',10);
                text(10,550,['expected in dist: ', num2str(expectedCountsDistHist)],'Color','y','FontSize',10);
                text(10,700,['95% confidence: ', num2str([topConfCountsDistHist, botConfCountsDistHist])],'Color','y','FontSize',10);
            end
            
        end
        % scatter(allCols, allRows); % for scatter visualization of viable pixels (debugging)
%         if (exist('verboseFile', 'var') && ~isempty(verboseFile))
%             [~,~,ext] = fileparts(verboseFile);
%             ext = ext(2:end);
%             saveas(vf, verboseFile, ext);
%         end
        
    end
    
end

    
    
% store area hist, including normalization (will modify the figures when
% regions are excluded)

if (NNcumulative)
    AvCvD.dists = dists;
    AvCvD.allRndDists = allRndDists;
end

AvCvD.totalAttach = numGFP ./ totExtrapolateFactor;
AvCvD.inDistHist = countDistHist ./ totExtrapolateFactor;
AvCvD.distArea = totalAreaAtDist;
AvCvD.relHist = relativeCountDistHist;

AvCvD.expHist = expectedCountsDistHist;

AvCvD.topConf = topConfCountsDistHist ./ totExtrapolateFactor;
AvCvD.botConf = botConfCountsDistHist ./ totExtrapolateFactor;
AvCvD.avgConf = avgConfCountsDistHist ./ totExtrapolateFactor;

AvCvD.topConfAnalytic = topConfCountsDistHistAnalytic;
AvCvD.botConfAnalytic = botConfCountsDistHistAnalytic;

% store area and dist bins

% AvCvD.countBins = countBins;
AvCvD.distBins = distBins;

% AvCvD.countBinsStr = [num2str(countBins), '-', num2str(countBins )];
% AvCvD.distBins = distBins;

AvCvD.accumDist = accumDist;
AvCvD.BFareas = BFprops.areas;
AvCvD.BFtotArea = numel(viablePixelsFromMask(:));
AvCvD.GFPareas = GFPprops.areas;
AvCvD.GFPtotArea = AvCvD.BFtotArea;

if (~isempty(removedRegionsMask))
    GFPprops = getPropsForSeg(imGFP_BW, removedRegionsMask);
    BFprops = getPropsForSeg(imBF_BW, removedRegionsMask);
    AvCvD.BFareas = BFprops.areas;
    AvCvD.GFPareas = GFPprops.areas;
end

disp(['Observed in the range ', num2str(AvCvD.distBins(1)*getCalibr), '-', num2str(AvCvD.distBins(2)*getCalibr), ': ', num2str(AvCvD.inDistHist(1)), ', envelope: [', num2str(AvCvD.botConf(1)), ',', num2str(AvCvD.topConf(1)), '] (avg: ', num2str(AvCvD.avgConf(1)), ')']);

end
    
    

function props = parseParams(v)
% default:
props = struct(...
    'static','BF',...
    'dynamic','GFP',...
    'distBins', [1, 12.5*power(2, 0:9)],...
    'randomizationBFOverlap', 'none',...
    'removeGFPFoundOnBF',true,...
    'allowMaxOverlapPerc', 100,...
    'isPerPixel', false,...
    'aggregateRandomizationNoSelfOverlap', true,...
    'NNcumulative', false,...
    'verbose', false,...
    'verboseFigs', 2,...
    'verboseOpts', [1 4],...
    'numOfBinsVisualize', 2,...
    'fluorescenceIntensityFactor', true,...
    'normalizePerWellSize',0 % 0 for no normalization
    
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'static'))
        props.static = v{i+1};     
    elseif (strcmp(v{i}, 'dynamic'))
        props.dynamic = v{i+1};     
    elseif (strcmp(v{i}, 'distBins'))
        props.distBins = v{i+1};             
    elseif (strcmp(v{i}, 'randomizationBFOverlap'))
        props.randomizationBFOverlap = v{i+1};     
    elseif (strcmp(v{i}, 'removeGFPFoundOnBF'))
        props.removeGFPFoundOnBF = v{i+1};             
    elseif (strcmp(v{i}, 'allowMaxOverlapPerc'))
        props.allowMaxOverlapPerc = v{i+1};     
    elseif (strcmp(v{i}, 'isPerPixel'))
        props.isPerPixel = v{i+1};             
    elseif (strcmp(v{i}, 'aggregateRandomizationNoSelfOverlap'))
        props.aggregateRandomizationNoSelfOverlap = v{i+1};     
    elseif (strcmp(v{i}, 'NNcumulative'))
        props.NNcumulative = v{i+1};             
    elseif (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};     
    elseif (strcmp(v{i}, 'verboseFigs'))
        props.verboseFigs = v{i+1};             
    elseif (strcmp(v{i}, 'verboseOpts'))
        props.verboseOpts = v{i+1};     
    elseif (strcmp(v{i}, 'numOfBinsVisualize'))
        props.numOfBinsVisualize = v{i+1};             
    elseif (strcmp(v{i}, 'fluorescenceIntensityFactor'))
        props.fluorescenceIntensityFactor = v{i+1};     
    elseif (strcmp(v{i}, 'normalizePerWellSize'))
        props.normalizePerWellSize = v{i+1};                     
    end
    
end

end