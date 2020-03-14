function showLiveDeadCoverage(m, params)

props = parseParams(params);

if strcmp(props.mode, 'ratio')
    showLiveDeadCoverage_ratio(m, props)
else    
    showLiveDeadCoverage_area(m, props)
end

set(gca,'xscale',props.xscale);
set(gca,'yscale',props.yscale);

if(~isempty(props.xlim))
    xlim(props.xlim);
end
if(~isempty(props.ylim))
    ylim(props.ylim);
end

box on
end

function showLiveDeadCoverage_area(m, props)

% plot(m.timePoints, m.liveArea./m.totalArea,'go-')
% plot(m.timePoints, m.deadArea./m.totalArea,'ro-')
x = m.timePoints;

ratios = nan(size(x));
ratiosSTD = nan(size(x));
for i = 1:numel(x)
    deadAtTimePoint = m.deadArea{i}./m.totalArea{i};
    dead(i) = mean(deadAtTimePoint);
    deadSTD(i) = std(deadAtTimePoint);

    liveAtTimePoint = m.liveArea{i}./m.totalArea{i};
    live(i) = mean(liveAtTimePoint);
    liveSTD(i) = std(liveAtTimePoint);
    
    cellsAtTimePoint = m.liveArea{i} + m.deadArea{i};
    cells(i) = mean(cellsAtTimePoint);
    cellsSTD(i) = std(cellsAtTimePoint);

end

y = dead;
yerr = deadSTD;
[x, timeOrder] = sort(x);
y = y(timeOrder);


 h = errorbar(x, y, yerr, 'o-','LineWidth', 2)
 color = get(h, 'Color');
%errorbar(x, y, yerr, 'go-','LineWidth', 2)


y = live;
yerr = liveSTD;
[x, timeOrder] = sort(x);
y = y(timeOrder);

errorbar(x, y, yerr, 'o--','LineWidth', 2, 'Color', color)
%errorbar(x, y, yerr, 'ro-','LineWidth', 2)

xlabel('time [hours]')
%ylabel('fraction of area covered')

set(gca,'yscale','log');
ylim([1e-6,1])
end


function showLiveDeadCoverage_ratio(m, props)

% plot(m.timePoints, m.liveArea./m.totalArea,'go-')
% plot(m.timePoints, m.deadArea./m.totalArea,'ro-')
x = m.timePoints;

ratios = nan(size(x));
ratiosSTD = nan(size(x));
for i = 1:numel(x)
    ratiosAtTimePoint = m.liveArea{i} ./ (m.deadArea{i}+m.liveArea{i});
    ratios(i) = mean(ratiosAtTimePoint);
    ratiosSTD(i) = std(ratiosAtTimePoint)
end

y = ratios;
yerr = ratiosSTD;

[x, timeOrder] = sort(x);
y = y(timeOrder);

errorbar(x, y, yerr, 'o-','LineWidth', 2)
%set(gca,'yscale','log');
xlabel('time [hours]')
ylabel('fraction of a506')
box on;
end


function props = parseParams(v)
% default:
props = struct(...
    'mode', 'ratio', ...
    'xscale','linear',...
    'yscale','linear', ...
    'xlim', [], ...
    'ylim', [] ...
);

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'mode'))
        props.mode = v{i+1};
    elseif (strcmp(v{i}, 'xscale'))
        props.xscale = v{i+1};
    elseif (strcmp(v{i}, 'yscale'))
        props.yscale = v{i+1};
    elseif (strcmp(v{i}, 'xlim'))
        props.xlim = v{i+1};
    elseif (strcmp(v{i}, 'ylim'))
        props.ylim = v{i+1};
    end
end

end
