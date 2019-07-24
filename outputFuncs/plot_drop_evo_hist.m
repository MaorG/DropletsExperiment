function h = plot_drop_evo_hist(m, properties)

props = parseParams(properties, m.dataParameters);

% edges = [-inf, logspace(log10(0.5), log10(2), 12), inf];
edges = round(props.edges, 2);

areasStart = m.areasStart;
areasEnd = m.areasEnd;

cellType = props.cellType;
    
hc = histcounts(areasEnd ./ areasStart, edges);
bar(hc);
yl = ylim;
line([7,7],[0,yl(2)],'Color','black','LineStyle','--');
set(gca, 'XTick', 1:numel(hc), 'XTickLabel', createSpacedMatrix(edges, 'range'));
xtickangle(45);
xlabel('new_area/old_area (Time 2 / Time 1)', 'Interpreter', 'none');
ylabel('# of droplets');

h.titl = [cellType, ' ', m.dataParameters.well, '.', num2str(m.dataParameters.repeat)];

if (isfield(props, 'graphPos'))
    set(gcf, 'OuterPosition', replacePositiveVals(get(gcf, 'OuterPosition'), props.graphPos));
end

end


function props = parseParams(v, dataParams)
% default:
props = struct(...
    'style','-', ...
    'LineWidth',3, ...
    'color',[18/255,110/255,20/255], ...
    'cellType', '' ...
    );

viewOrderAll = [];

for i = 1:numel(v)
    if (strcmpi(v{i}, 'style'))
        props.style = v{i+1};
    elseif (strcmpi(v{i}, 'LineWidth'))
        props.LineWidth = v{i+1};
    elseif (strcmpi(v{i}, 'color'))
        props.color = v{i+1};
    elseif (strcmpi(v{i}, 'cellType'))
        props.cellType = v{i+1};
    elseif (strcmpi(v{i}, 'edges'))
        props.edges = v{i+1};      
    elseif (strcmpi(v{i}, 'graphPos'))
        props.graphPos = v{i+1};        
    elseif (strcmpi(v{i}, 'viewOrder'))
        viewOrderAll = [viewOrderAll, {v{i+1}}];
    end
end

props = customParametrizeToProps(viewOrderAll, props, dataParams);
    
end