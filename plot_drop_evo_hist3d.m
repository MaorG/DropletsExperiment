function h = plot_drop_evo_hist3d(m, properties)

props = parseParams(properties, m.dataParameters);

cellType = props.cellType;

areasStart = m.areasStart;
areasEnd = m.areasEnd;
cAreasStart = m.cAreasStart;
ratioStart = m.ratioStart;

scatter(areasStart, areasEnd./areasStart, [], log10(cAreasStart))
set(gca, 'xscale', 'log');
set(gca, 'yscale', 'log');
%set(gca, 'zscale', 'log');
colorbar;

caxis([0,3])
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
    elseif (strcmpi(v{i}, 'graphPos'))
        props.graphPos = v{i+1};
    elseif (strcmpi(v{i}, 'viewOrder'))
        viewOrderAll = [viewOrderAll, {v{i+1}}];
    end
end

props = customParametrizeToProps(viewOrderAll, props, dataParams);
    
end