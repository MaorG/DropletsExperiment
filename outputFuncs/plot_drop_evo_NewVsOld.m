function h = plot_drop_evo_NewVsOld(m, properties)

props = parseParams(properties, m.dataParameters);

areasStart = m.areasStart;
areasEnd = m.areasEnd;

cellType = props.cellType;

scatter(areasStart, areasEnd);
plot([1,1e5],[1,1e5],'k--');
set(gca, 'xscale', 'log');
set(gca, 'yscale', 'log');
xlabel('Time 1');
ylabel('Time 2');
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