function showDensityCorr(m, params)

props = parseParams(params);
for ri = 1:numel(m.pool)
    if props.radius/0.16 == m.pool(ri).radius
        showDensityCorrAux(m.pool(ri), params)
        text(0.1,0.1,[ 'r: ' num2str(m.pool(ri).radius)],'units','normalized');
    end
end

end

function showDensityCorrAux(m, params, radius)

props = parseParams(params);

if strcmp(props.mode, 'bins')
    showDCBinning(m, props);
else
    showDCCummulative(m, props);

end
    % version 1: binning
end

function showDCBinning(m, props)

expDensities = m.res.expDensities;
allRndDensities = m.res.allRndDensities;
repeats = numel(allRndDensities);

confidence = props.confidence;
densityBins = props.distBins;

hold on;

allRandHists = [];
for ri = 1:repeats
    rndHist = histcounts(allRndDensities{ri} ,densityBins);

    allRandHists = cat(1,allRandHists ,rndHist);
    if props.showAll
        plot(densityBins(1:end-1), rndHist+1, 'r');
    end
end

allRandHistsSorted = sort(allRandHists,1);
margin = ceil(confidence*repeats);

if props.showAll
    plot(densityBins(1:end-1),allRandHistsSorted (margin,:) ,'k');
    plot(densityBins(1:end-1),allRandHistsSorted (end - margin + 1,:),'k');
else
    meanARHS = mean(allRandHistsSorted,1);
    diffARHStop = allRandHistsSorted (margin,:) - meanARHS;
    diffARHSbot = meanARHS - allRandHistsSorted (end - margin + 1,:);
    shadedErrorBar(densityBins(1:end-1), meanARHS, diffARHSbot, diffARHStop,'k') 
end
expHist = histcounts(expDensities ,densityBins);
if props.showAll
    plot(densityBins(1:end-1), expHist + 1, 'b','LineWidth', 2);
else
    plot(densityBins(1:end-1), expHist + 1, 'k','LineWidth', 2);
end

set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')

end

function showDCCummulative(m, props)

expDensities = m.res.expDensities;
allRndDensities = m.res.allRndDensities;
repeats = numel(allRndDensities);

confidence = props.confidence;

hold on;
for ri = 1:repeats
    density = allRndDensities{ri};
    [densitiesSorted, order] = sort(density,'descend');
    %y = (1:numel(distancesSorted))./ numel(distancesSorted);
    y = (1:numel(densitiesSorted));
    plot(densitiesSorted,y,'r')
end
hold on;
% envelope: sample curves at intervals


sortedY = [];
maxX = max (cat(2,allRndDensities{:}));
minX = min (cat(2,allRndDensities{:}));
dx = (maxX-minX)/100;
xq = minX:dx:maxX;
for ri = 1:repeats
    density = allRndDensities{ri};
    [densitiesSorted, order] = sort(density,'descend');
    x = densitiesSorted;
%    y = (1:numel(distancesSorted))./ numel(distancesSorted);
    y = (1:numel(densitiesSorted));
    [x,yi] = unique(x);
    y = y(yi);
    yq = interp1(x,y,xq,'linear','extrap');
    sortedY = cat(1,sortedY,yq);
end
sortedSortedY = sort(sortedY,1);
sortedSortedY = max(sortedSortedY,0);
sortedSortedY = min(sortedSortedY,numel(densitiesSorted));

margin = ceil(confidence*repeats);
plot(xq,sortedSortedY(margin,:),'k');
plot(xq,sortedSortedY(end - margin + 1,:),'k');

hold on;
[densitiesSorted, order] = sort(expDensities,'descend');
y = (1:numel(densitiesSorted))./ numel(densitiesSorted);
y = (1:numel(densitiesSorted));
plot(densitiesSorted,y,'b','LineWidth', 2)

set(gca, 'yscale', 'log')
end

function props = parseParams(v)
% default:
props = struct(...
    'mode', 'bins',...
    'distBins',0:1:200, ...
    'confidence', 0.01, ...
    'cumulative', 0, ...
    'showAll', 0, ...
    'radius', [] ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'mode'))
        props.mode = v{i+1};
    elseif (strcmp(v{i}, 'distBins'))
        props.distBins = v{i+1};
    elseif (strcmp(v{i}, 'confidence'))
        props.confidence = v{i+1};
    elseif (strcmp(v{i}, 'cumulative'))
        props.cumulative = v{i+1};
    elseif (strcmp(v{i}, 'showAll'))
        props.showAll = v{i+1};
    elseif (strcmp(v{i}, 'radius'))
        props.radius = v{i+1};
    end
end

end



