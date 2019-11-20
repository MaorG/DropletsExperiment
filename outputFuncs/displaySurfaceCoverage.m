function displaySurfaceCoverage(m, properties)
props = parseParams(properties);

if isstruct(m)
    if numel(m) == 1
        plot(m.X(1:numel(m.Y))* props.timeScale,m.Y,'-o', 'LineWidth', 2)
    else
        plot(cat(1,m.X)* props.timeScale,cat(1,m.Y),'-o', 'LineWidth', 2)
    end
else
    timepoints = 1:numel(m);
    timepoints = timepoints * props.timeScale;
    plot( timepoints, m, '-o', 'LineWidth', 2)
end
set(gca,'xscale',props.xscale);
set(gca,'yscale',props.yscale);

if(~isempty(props.xlim))
    xlim(props.xlim);
end
if(~isempty(props.ylim))
    ylim(props.ylim);
end

set(gca,'LineWidth',2)
set(gca,'FontSize',14)
box on

end

function props = parseParams(v)
% default:
props = struct(...
    'timeScale', 1.0, ...
    'xscale','linear',...
    'yscale','linear', ...
    'xlim', [], ...
    'ylim', [] ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'timeScale'))
        props.timeScale = v{i+1};
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
