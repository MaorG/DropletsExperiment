function showNN(m, params)

props = parseParams(params);

if strcmp(props.mode, 'bins')
    showNNBinning(m, props);
elseif strcmp(props.mode, 'nndd')
    showNNDD(m, props);
elseif strcmp(props.mode, 'zscore')
    showNNZScore(m, props);
else
    showNNCummulative(m, props);

end
    % version 1: binning
end

function showNNZScore(m, props)

hold on;
expDistances = m.expDistances;
allRndDistances = m.allRndDistances;
repeats = numel(allRndDistances);

xv = props.zsample;

colors = hsv(numel(xv));

tot = numel(expDistances);

for i = 1:numel(xv)
    x = xv(i);
    

    [expDistancesSorted, order] = sort(expDistances);
    ye = find(expDistancesSorted <= x, 1, 'last')
    yrv = [];
    for ri = 1:repeats
        dist = allRndDistances{ri};
        [distancesSorted, order] = sort(dist);
        %y = (1:numel(distancesSorted))./ numel(distancesSorted);
        yr = find(distancesSorted <= x, 1, 'last');
        yrv(end+1) = yr;
    end
    [Z,mu,sigma] = zscore(yrv)
    X = 1:tot;
    Y = normpdf(X,mu,sigma);
    
    ezscore = (ye-mu)/sigma;
    
    plot(X,Y,'Color', colors(i,:));
    scatter(yrv, max(Y(:))*0.1*(1+rand(numel(yrv),1)),[],colors(i,:));
    plot([ye,ye],[0,max(Y(:))],'Color', colors(i,:), 'LineWidth', 2);
    text(ye,max(Y(:)),num2str(ezscore),'Color', colors(i,:));
end
    
end

function showNNDD(m, props)
hold on
res = m;

repeats = numel(res.allRndDD);

for ri = 1:repeats

    if (props.cumulative)
        plot(res.allRndDD(ri).bins, (cumsum(res.allRndDD(ri).dyn) ./ cumsum(res.allRndDD(ri).tot)), 'r')    
    else
        plot(res.allRndDD(ri).bins, (res.allRndDD(ri).dyn ./ res.allRndDD(ri).tot), 'r')
    end
end

if (props.cumulative)
    plot(res.expDD.bins, (cumsum(res.expDD.dyn) ./ cumsum(res.expDD.tot)), 'b')
else
    plot(res.expDD.bins, (res.expDD.dyn ./ res.expDD.tot), 'b')
end
set(gca, 'xscale', 'log')
xlabel({'distance [um]'})
ylabel({'fraction covered'})
end

function showNNBinning(m, props)

expDistances = m.expDistances;
allRndDistances = m.allRndDistances;
repeats = numel(allRndDistances);

confidence = props.confidence;
distanceBins = props.distBins;

hold on;
allRandHists = [];
for ri = 1:repeats
    rndHist = histcounts(allRndDistances{ri} ,distanceBins);
    plot(distanceBins(1:end-1), rndHist, 'r');
    allRandHists = cat(1,allRandHists ,rndHist);
end
allRandHistsSorted = sort(allRandHists,1);
margin = ceil(confidence*repeats);
plot(distanceBins(1:end-1),allRandHistsSorted (margin,:),'k');
plot(distanceBins(1:end-1),allRandHistsSorted (end - margin + 1,:),'k');

expHist = histcounts(expDistances ,distanceBins);
plot(distanceBins(1:end-1), expHist, 'b','LineWidth', 2);

end

function showNNCummulative(m, props)


expDistances = m.expDistances;
allRndDistances = m.allRndDistances;
repeats = numel(allRndDistances);

confidence = props.confidence;

if (isempty(expDistances))
    return;
end

hold on;
for ri = 1:repeats
    dist = allRndDistances{ri};
    [distancesSorted, order] = sort(dist);
    %y = (1:numel(distancesSorted))./ numel(distancesSorted);
    y = (1:numel(distancesSorted));
    if props.showAll
        plot(distancesSorted,y,'r')
    end
end
hold on;
% envelope: sample curves at intervals


sortedY = [];
maxX = max (cat(2,allRndDistances{:}));
minX = min (cat(2,allRndDistances{:}));
xq = minX:0.1:maxX;
for ri = 1:repeats
    dist = allRndDistances{ri};
    [distancesSorted, order] = sort(dist);
    x = distancesSorted;
%    y = (1:numel(distancesSorted))./ numel(distancesSorted);
    y = (1:numel(distancesSorted));
    [x,yi] = unique(x);
    y = y(yi);
    yq = interp1(x,y,xq,'linear','extrap');
    sortedY = cat(1,sortedY,yq);
end
sortedSortedY = sort(sortedY,1);
sortedSortedY = max(sortedSortedY,0);
sortedSortedY = min(sortedSortedY,numel(distancesSorted));

margin = ceil(confidence*repeats);
if props.showAll
    plot(xq,sortedSortedY(margin,:),'k');
    plot(xq,sortedSortedY(end - margin + 1,:),'k');
else 
    meanY = median(sortedSortedY);
    errYbot = meanY - sortedSortedY(end - margin + 1,:);
    errYtop = sortedSortedY(margin,:) - meanY;
    shadedErrorBar(xq,1+meanY,[-errYbot;-errYtop],'lineprops','k--');
end
hold on;
[distancesSorted, order] = sort(expDistances);
y = (1:numel(distancesSorted))./ numel(distancesSorted);
y = (1:numel(distancesSorted));

if props.showAll
    plot(distancesSorted,y,'b','LineWidth', 2)
else
    plot(distancesSorted,y,'k-','LineWidth', 2)
end

%set(gca, 'yscale', 'log')
set(gca,'LineWidth',2)
set(gca,'FontSize',14)
box on
xlabel('distance [\mum]')
ylabel('No. of cell within distance')


end

function props = parseParams(v)
% default:
props = struct(...
    'mode', 'bins',...
    'distBins',0:1:200, ...
    'confidence', 0.01, ...
    'showAll', 0, ...
    'cumulative', 0, ...
    'zsample', 2 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'mode'))
        props.mode = v{i+1};
    elseif (strcmp(v{i}, 'distBins'))
        props.distBins = v{i+1};
    elseif (strcmp(v{i}, 'confidence'))
        props.confidence = v{i+1};
    elseif (strcmp(v{i}, 'showAll'))
        props.showAll = v{i+1};
    elseif (strcmp(v{i}, 'cumulative'))
        props.cumulative = v{i+1};
    elseif (strcmp(v{i}, 'zsample'))
        props.zsample = v{i+1};
    end
end

end



