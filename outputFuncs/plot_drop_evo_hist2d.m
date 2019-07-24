function h = plot_drop_evo_hist2d(m, properties)

props = parseParams(properties, m.dataParameters);

areasStart = m.areasStart;
areasEnd = m.areasEnd;

cellType = props.cellType;

% edges = [-inf, logspace(log10(0.5), log10(2), 12), inf];
edges = round(props.edges, 2);
% areaEdges = [100,300,1000,3000,inf];
areaEdges = props.areaEdges;

N = histcounts2(areasEnd ./ areasStart, areasStart, edges, areaEdges);
ylabel('new_area/old_area (Time 2 / Time 1)', 'Interpreter', 'none');
set(gca, 'YTick', 1:2:numel(edges)-1, 'YTickLabel', sqrt(edges(1:2:end-1).*edges(2:2:end)));
xlabel('old area');
set(gca, 'XTick', 1:numel(areaEdges)-1, 'XTickLabel', createSpacedMatrix(areaEdges, 'range'));
zlabel('# of droplets');
bar3nan(N);
view([1,-1,1])

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
    elseif (strcmpi(v{i}, 'areaEdges'))
        props.areaEdges = v{i+1};     
    elseif (strcmpi(v{i}, 'graphPos'))
        props.graphPos = v{i+1};        
    elseif (strcmpi(v{i}, 'viewOrder'))
        viewOrderAll = [viewOrderAll, {v{i+1}}];
    end
end

props = customParametrizeToProps(viewOrderAll, props, dataParams);
    
end