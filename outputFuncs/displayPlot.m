function displayPlot(m, properties)
props = parseParams(properties);

 colorOrder = zeros(1,5);
 colorOrder = hsv(3)
 
 set(0, 'DefaultAxesColorOrder', colorOrder)
 set(0, 'DefaultAxesLineStyleOrder', {'-o', '-s', '-x'})

if isstruct(m)
    if numel(m) == 1
        plot(m.X,m.Y, 'LineWidth', 2, 'MarkerSize', 7, 'MarkerFaceColor', [1,1,1])
    else
        plot(cat(1,m.X),cat(1,m.Y),'-o', 'LineWidth', 2, 'MarkerSize', 7)
    end
else
    plot(m)
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
    'xscale','linear',...
    'yscale','linear', ...
    'xlim', [], ...
    'ylim', [] ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'xscale'))
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
