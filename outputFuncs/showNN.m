function showNN(m, params)

props = parseParams(params);

if strcmp(props.mode, 'bins')
    showNNBinning(m, props);
elseif strcmp(props.mode, 'nndd')
    showNNDD(m, props);
elseif strcmp(props.mode, 'zscore')
    showNNZScore(m, props);
elseif strcmp(props.mode, 'relative')
    showRelativeToEnvelope(m, props)
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
        if(isempty(yr))
           yr = 0;
        end
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
        plot(res.allRndDD(ri).bins, (cumsum(res.allRndDD(ri).dyn) ./ cumsum(res.allRndDD(ri).tot)), 'k')    
    else
        plot(res.allRndDD(ri).bins, (res.allRndDD(ri).dyn ./ res.allRndDD(ri).tot), 'k')
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
    %plot(distanceBins(1:end-1), rndHist, 'r');
    %plot(distanceBins(1:end-1), rndHist./distanceBins(1:end-1), 'r');
    allRandHists = cat(1,allRandHists ,rndHist);
end
allRandHistsSorted = sort(allRandHists,1);
margin = ceil(confidence*repeats);

meanAllRandomHistSorted = mean(allRandHistsSorted,1);
conf_top = allRandHistsSorted (margin,:);
conf_bot = allRandHistsSorted (end - margin + 1,:);

expHist = histcounts(expDistances ,distanceBins);


colors = hsv(6);
colors = colors*0.75;
nnn = numel(get(gca,'Children'))
iii = floor(nnn)/5+1


normFactor = m.A/(m.N1*m.N2);
X = distanceBins(1:end-1);
rY = meanAllRandomHistSorted/normFactor;
rYerr1 = (meanAllRandomHistSorted - conf_bot)/normFactor;
rYerr2 = (conf_top - meanAllRandomHistSorted)/normFactor;
%rE1 = 
%rE2 = 
hold on
%shadedErrorBar(distanceBins(1:end-1),meanAllRandomHistSorted, ...
%    [meanAllRandomHistSorted - conf_bot; conf_top - meanAllRandomHistSorted], {'Color', colors(iii,:)},1);
%plot(distanceBins(1:end-1), max(0,(expHist)), 'Color', colors(iii,:),'LineWidth', 2);
rrrr = sum(meanAllRandomHistSorted)/sum(expHist)
plot(distanceBins(1:end-1), rrrr*max(0,(expHist))./meanAllRandomHistSorted, 'Color', colors(iii,:),'LineWidth', 2);

% shadedErrorBar(distanceBins(1:end-1),meanAllRandomHistSorted./distanceBins(1:end-1), ...
%     [meanAllRandomHistSorted - conf_bot; conf_top - meanAllRandomHistSorted]./distanceBins(1:end-1), {'Color', colors(iii,:)},1);
% plot(distanceBins(1:end-1), max(0,(expHist))./distanceBins(1:end-1), 'Color', colors(iii,:),'LineWidth', 2);

if ~isempty(props.exportResultsDirName)
    mkdir(props.exportResultsDirName)
    X = distanceBins(1:end-1);
    %T = table(X', expHist', expHist', expHist',meanAllRandomHistSorted', meanAllRandomHistSorted', meanAllRandomHistSorted');
    T = table(X', expHist'/normFactor, expHist'/normFactor, expHist'/normFactor,meanAllRandomHistSorted'/normFactor, meanAllRandomHistSorted'/normFactor, meanAllRandomHistSorted'/normFactor);
    T.Properties.VariableNames = {'X','Y', 'E1', 'E2', 'Yr', 'Er1', 'Er2'}
    name = m.name;
    writetable(T,[props.exportResultsDirName, name, '.txt'],'Delimiter','\t')

end
    
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

if strcmp(props.norm, 'area')
    %factor = 1/ 0.9033;
     factor = 1;
elseif strcmp(props.norm, 'fraction')
    factor = 1/max(y);
else
    factor = 1;
end

margin = ceil(confidence*repeats);
if props.showAll
    plot(xq,sortedSortedY(margin,:)*factor,'k');
    plot(xq,sortedSortedY(end - margin + 1,:)*factor,'k');
else 
    meanY = mean(sortedSortedY);
    errYbot = meanY - sortedSortedY(end - margin + 1,:);
    errYtop = sortedSortedY(margin,:) - meanY;
    

        
    nnn = numel(get(gca,'Children'))
    if nnn < 5
        shadedErrorBar(xq,meanY*factor,[-errYbot;-errYtop]*factor,'-k', 1);
    elseif nnn < 10
        shadedErrorBar(xq,meanY*factor,[-errYbot;-errYtop]*factor,'-g', 1);
    elseif nnn < 15
        shadedErrorBar(xq,meanY*factor,[-errYbot;-errYtop]*factor,'-b', 1);
    else
        shadedErrorBar(xq,meanY*factor,[-errYbot;-errYtop]*factor,'-c', 1);
    end
    
end
hold on;
[distancesSorted, order] = sort(expDistances);
y = (1:numel(distancesSorted))./ numel(distancesSorted);
y = (1:numel(distancesSorted));

if props.showAll
    plot(distancesSorted,y*factor,'b','LineWidth', 2)
else
    nnn = numel(get(gca,'Children'))
    if nnn < 5
        plot(distancesSorted,y*factor,'k-','LineWidth', 2)
    elseif nnn < 10
        plot(distancesSorted,y*factor,'g-','LineWidth', 2)
    elseif nnn < 15
        plot(distancesSorted,y*factor,'b-','LineWidth', 2)
    else
        plot(distancesSorted,y*factor,'c-','LineWidth', 2)
    end

end

%set(gca, 'yscale', 'log')
set(gca,'LineWidth',2)
set(gca,'FontSize',14)
box on
xlabel('distance [\mum]')


if strcmp(props.norm, 'area')
    ylabel('No. of nearest neighbors within distance per mm^2');
elseif strcmp(props.norm, 'fraction')
    ylabel('Fraction of nearest neighbors within distance');
else
    ylabel('No. of nearest neighbors within distance');
end


end

function props = parseParams(v)
% default:
props = struct(...
    'mode', 'bins',...
    'distBins',0:1:200, ...
    'confidence', 0.01, ...
    'showAll', 0, ...
    'cumulative', 0, ...
    'zsample', 2, ...
    'exportResultsDirName', '',...
    'norm', 'none' ...
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
    elseif (strcmp(v{i}, 'exportResultsDirName'))
        props.exportResultsDirName = v{i+1};
    elseif (strcmp(v{i}, 'norm'))
        props.norm = v{i+1};
    end
end

end



function showRelativeToEnvelope(m, props)


expDistances = m.expDistances;
allRndDistances = m.allRndDistances;
repeats = numel(allRndDistances);

confidence = props.confidence;

if (isempty(expDistances))
    return;
end

hold on;
% envelope: sample curves at intervals
sortedY = [];
maxX = max (cat(2,allRndDistances{:}));
minX = min (cat(2,allRndDistances{:}));
xq = 1:0.1:min(maxX,40);
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

meanY = median(sortedSortedY);
errYbot = meanY - sortedSortedY(end - margin + 1,:);
errYtop = sortedSortedY(margin,:) - meanY;
    

        
[distancesSorted, order] = sort(expDistances);
x = distancesSorted;
y = (1:numel(distancesSorted));
[x,yi] = unique(x);
y = y(yi);
yq = interp1(x,y,xq,'linear','extrap');

yTopRelative = (yq-meanY)./(-errYbot);
yBotRelative = (yq-meanY)./(-errYtop);

yrel = yTopRelative .* (yq>meanY) + yBotRelative .* (yq<=meanY); 

nnn = numel(get(gca,'Children'))
if nnn < 1
    plot(xq([1,end]),[1,1],'k--','LineWidth', 2);
    plot(xq([1,end]),[-1,-1],'k--','LineWidth', 2);
end

nnn = numel(get(gca,'Children'))
iii = nnn - 1;
colors = hsv(4);
plot(xq,yrel,'-','LineWidth', 3, 'Color', colors(iii,:));


ylim auto
yl = ylim
ylim([min(yl(1),-3),max(yl(2),3)]);
ylim([-3,5]);
xlim([0,20]);

%set(gca, 'yscale', 'log')
set(gca,'LineWidth',2)
set(gca,'FontSize',14)
box on
xlabel('distance [\mum]')
ylabel('^{(observed - expected)}/_{(confidence interval)}');



end
