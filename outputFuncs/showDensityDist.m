function showDensityDist(m, params)

props = parseParams(params);

for ri = 1:numel(m.pool)
    if props.radius/0.16 == m.pool(ri).radius
        showDensityDistAux(m.pool(ri).res, params)
        text(0.1,0.1,[ 'r: ' num2str(m.pool(ri).radius)],'units','normalized');
    end
end

end

function showDensityDistAux(m, params)

props = parseParams(params);

bins = m.bins;
Nexp = m.Nexp;
Nrnd = m.Nrnd;
binMerge = props.binMerge;
% merge bins

if props.binMerge > 1
    lastBinIndex = binMerge*floor(numel(Nexp)/binMerge);
    bins = bins(1:binMerge:lastBinIndex+1);
    Nexp = sum(reshape(Nexp(1:lastBinIndex), binMerge, []));
    for i = 1:numel(Nrnd)
        Nrnd{i} = sum(reshape(Nrnd{i}(1:lastBinIndex), binMerge, []));
    end
end




hold on;

if props.showAll
    for i = 1:numel(Nrnd)
        plot(bins(1:end-1), Nrnd{i},'r');
    end
end

Y = cat(1,Nrnd{:});
sortedY = sort(Y,1);

margin = ceil(props.confidence*numel(Nrnd));

if props.showAll
    plot(bins(1:end-1),sortedY(margin,:),'k');
    plot(bins(1:end-1),sortedY(end - margin + 1,:),'k');
else
    meanY = median(sortedY,1);
    errYbot = meanY - sortedY(end - margin + 1,:);
    errYtop = sortedY(margin,:) - meanY;
    shadedErrorBar(bins(1:end-1),1+meanY,[-errYbot;-errYtop],'lineprops','k--');
end

if props.showAll
    plot(bins(1:end-1), Nexp,'b');
else
    plot(bins(1:end-1), Nexp,'k-', 'LineWidth', 2);
end

vi = max(find(sortedY(end - margin + 1,:), 1, 'last') ,find(Nexp, 1, 'last'));

xl = xlim;
xlim([0,1.1*bins(vi)]);


%set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
set(gca,'LineWidth',2)
set(gca,'FontSize',14)
box on
xlabel('local density')
ylabel('pixel count')

end

function props = parseParams(v)
% default:
props = struct(...
    'radius', 50, ...
    'confidence', 0.05, ...
    'binMerge', 1, ...
    'showAll', 0 ...
);

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'confidence'))
        props.confidence = v{i+1};
    elseif (strcmp(v{i}, 'radius'))
        props.radius = v{i+1};
    elseif (strcmp(v{i}, 'binMerge'))
        props.binMerge = v{i+1};
    elseif (strcmp(v{i}, 'showAll'))
        props.showAll = v{i+1};
    end
end

end
