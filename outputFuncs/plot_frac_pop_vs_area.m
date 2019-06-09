function h = plot_frac_pop_vs_area(m, properties)

props = parseParams(properties, m.dataParameters);

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


function props = parseParams(v, dataParams)
% default:
props = struct(...
    'style','-', ...
    'LineWidth',3, ...
    'color',[18/255,110/255,20/255] ...
    );

viewOrder = [];

for i = 1:numel(v)
    if (strcmpi(v{i}, 'style'))
        props.style = v{i+1};
    elseif (strcmpi(v{i}, 'LineWidth'))
        props.LineWidth = v{i+1};
    elseif (strcmpi(v{i}, 'color'))
        props.color = v{i+1};
    
    elseif (strcmpi(v{i}, 'viewOrder'))
        viewOrder = v{i+1};
        
        % example for v that changes plotting style for different plots:
        % 'viewOrder' {{'time' 'well'} {'style' 'color' 'LineWidth'} {{0 2} {1 2} {2 3}}} 'style' {'-' '--' '-.'} 'color' {[18/255 110/255 20/255] 'r' 'k'} 'LineWidth' 3
        % this uses the 'time' and 'well' properties designated by {0 2},
        % {1 2} and {2 3} (in that order) and chooses the style properties
        % specified by 'style', 'color' and 'LineWidth' by the index that
        % corresponds to that matched by the current plot properties of
        % 'time' and 'well'; LineWidth will stay 3 because there is one
        % option only
        
    end
end

if (~isempty(viewOrder) && exist('dataParams', 'var'))
    dataParamsNames = viewOrder{1};
    dataParamsOpts = viewOrder{3};
    propsToChange = viewOrder{2};
    isCurParamsEq = zeros(numel(dataParamsOpts), numel(dataParamsOpts{1}));
    for i = 1 : numel(dataParamsNames)
        parName = dataParamsNames{i};
        if (isfield(dataParams, parName))
            curParam = dataParams.(parName);
            for ii = 1 : numel(dataParamsOpts)
                specParam = dataParamsOpts{ii}{i};
                isEq = 0;
                if (isnumeric(curParam))
                    isEq = curParam == specParam;
                else
                    isEq = strcmp(curParam, specParam);
                end
                isCurParamsEq(ii, i) = any(isEq);
            end
                
        end
    end
    
    pos = [];
    isCurParamsEq = all(isCurParamsEq, 2);
    posCurParamsEq = find(isCurParamsEq);
    pos = posCurParamsEq(1);
    if (~isempty(pos))
        for i = 1 : numel(propsToChange)
            curProp = propsToChange{i};
            if (isfield(props, curProp))
                curPropVal = props.(curProp);
                if (iscell(curPropVal))
                    if (pos <= numel(curPropVal))
                        curPropVal = curPropVal{pos};
                    else
                        curPropVal = curPropVal{1};
                    end
                end
                props.(curProp) = curPropVal;
            end
        end
    end
    
end
    
end