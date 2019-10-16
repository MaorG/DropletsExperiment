function showDensityCorr(m, params)

props = parseParams(params);
for ri = 1:numel(m.pool)
    if props.radius/0.16 == m.pool(ri).radius
        showDensityCorrAux(m.pool(ri), params)
        text(0,0,[ 'r: ' num2str(m.pool(ri).radius)],'units','normalized');

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

%expDensities = m.expDensities;
expDensities = m.expDistances %!!!
allRndDensities = m.allRndDensities;
repeats = numel(allRndDensities);

confidence = props.confidence;
densityBins = props.distBins;

hold on;
allRandHists = [];
for ri = 1:repeats
    rndHist = histcounts(allRndDensities{ri} ,densityBins);
    plot(densityBins(1:end-1), rndHist+1, 'r');
    allRandHists = cat(1,allRandHists ,rndHist);
end
allRandHistsSorted = sort(allRandHists,1);
margin = ceil(confidence*repeats);

plot(densityBins(1:end-1),allRandHistsSorted (margin,:) +1 ,'k');
plot(densityBins(1:end-1),allRandHistsSorted (end - margin + 1,:) + 1,'k');

expHist = histcounts(expDensities ,densityBins);
plot(densityBins(1:end-1), expHist + 1, 'b','LineWidth', 2);

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
xq = minX:1:maxX;
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
    'confidence', 0.05, ...
    'cumulative', 0, ...
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
    elseif (strcmp(v{i}, 'radius'))
        props.radius = v{i+1};
    end
end

end



