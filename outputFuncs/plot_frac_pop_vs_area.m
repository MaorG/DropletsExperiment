function h = plot_frac_pop_vs_area(m, properties)

props = parseParams(properties);

[uas,ia,ic] = unique(m.X);
ufs = m.Y(ia);

xq = logspace(log10(min(m.X)), log10(max(m.X)), 300);

yq = interp1(uas,ufs,xq);

xq = [xq,xq(end)+2];
yq = [yq,0];

if strcmp( props.style, ':')
    ':'
    props.style = ':';
    if (props.LineWidth == 1)
        props.LineWidth = 2;
        props.color = (1.25*props.color);
        props.color = min(max(props.color,[0,0,0]),[1,1,1]);
    else
        props.color = (1.25*props.color);
        props.color = min(max(props.color,[0,0,0]),[1,1,1]);
    end
end

plot (xq, yq, 'Color', props.color, 'LineStyle', props.style, 'LineWidth',props.LineWidth);

% default plot configuration
xlabel('drop area');
ylabel('fraction of pop');
set(gca, 'xscale','log')
ylim([0,1]);

% plot beautification
% Create ylabel
ylabel('Fraction of population','FontWeight','bold');
% Create xlabel
xlabel('Droplet area [\mum^2]','FontWeight','bold');
axes1 = gca;
doFormat()
% legend(' Aggregated\it P. putida',' Solitary\it P. putida',' Beads', 'Location', 'NorthEast')
% legend('boxoff')
set(axes1,...
    'XTick',[100 1000 10000 100000],  ...
    'XTickLabel',{'10^2','10^3','10^4','10^5'}  ...
    );
xlim([10^1.4,10^5.5])
% saveas(gcf,'figures v4 alt bins/cumulative frac - aggs beads.fig')
% print('figures v4 alt bins/cumulative frac - aggs beads','-dtiff','-r300')


end


function props = parseParams(v)
% default:
props = struct(...
    'style','-', ...
    'LineWidth',3, ...
    'color',[18/255,110/255,20/255] ...
    );

for i = 1:numel(v)
    if (strcmpi(v{i}, 'style'))
        props.cellArea = v{i+1};
    elseif (strcmpi(v{i}, 'LineWidth'))
        props.cellSurvival = v{i+1};
    elseif (strcmpi(v{i}, 'color'))
        props.dropletArea = v{i+1};
    end
end

end