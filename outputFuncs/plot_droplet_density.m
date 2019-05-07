function plot_droplet_density(m, properties)

props = parseParams(properties);

X = m.X;
Y = m.Y;
Yerr = m.Yerr;
groupNum = m.groupNum;
groupNumPos = find(props.groupOrder == groupNum);

if (isempty(groupNumPos))
    fprintf(':( %d\n', groupNumPos);
    return;
end

errorbar(X,Y,Yerr,'Color', props.colors(groupNumPos,:),'LineWidth',3,'CapSize',10,'LineStyle', props.styles{groupNumPos}, 'Marker', props.MarkerStyles{groupNumPos}, 'MarkerSize', props.MarkerSizes(groupNumPos));

set(gca, 'yscale', 'log')
set(gca, 'xscale', 'log')
doFormat()
title([])
legend(props.legend{groupNumPos},'Location', 'NorthEast')
legend('boxoff')
ylabel('Droplet density [mm^{-2}]','FontWeight','bold');
xlabel('Droplet area [\mum^2]','FontWeight','bold');
xlim([10^1.5,10^5.5])
xlim([10^1.2,10^5])
ylim([10^-2,10^4])
axes1 = gca;
set(axes1,...
    'XTick',[10 100 1000 10000 100000],  ...
    'XTickLabel',{'10^1','10^2','10^3','10^4','10^5'},  ...
    'YTick',[0.1,1,10,100 1000 10000 100000],  ...
    'YTickLabel',{'10^{-1}', '10^0', '10^1', '10^2','10^3','10^4','10^5'}  ...
    );

set(gcf,'position',[50,50,1000,600])

% saveas(gcf,'figures v4 alt bins/droplet area distribution.fig')
% print('figures v4 alt bins/droplet area distribution','-dtiff','-r300')


end


function props = parseParams(v)
% default:
props = struct(...
    'colors', [18/255 110/255 20/255;123/255 74/255 43/255;0.5 0.5 0.5;0.5 0.5 0], ...
    'styles', {{'-' '-' '--' ':' ':'}}, ...
    'MarkerStyles', {{'o' 's' 'd'}}, ...
    'MarkerSizes',[6 6 6 6 6], ...
    'legend', 'legend', ...
    'groupOrder', [1 2 3 4 5] ...
    );

for i = 1:numel(v)
    if (strcmpi(v{i}, 'styles'))
        props.styles = v{i+1};
    elseif (strcmpi(v{i}, 'MarkerStyles'))
        props.MarkerStyles = v{i+1};
    elseif (strcmpi(v{i}, 'MarkerSizes'))
        props.MarkerSizes = v{i+1};        
    elseif (strcmpi(v{i}, 'colors'))
        props.colors = v{i+1};
    elseif (strcmpi(v{i}, 'legend'))
        props.legend = v{i+1};   
    elseif (strcmpi(v{i}, 'groupOrder'))
        props.groupOrder = v{i+1};
        
    end
end

end