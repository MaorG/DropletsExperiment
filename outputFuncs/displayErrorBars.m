function displayErrorBars(m, parameters)

props = parseParams(parameters);

if(isfield(m, 'Yste'))
    errorbar(m.X,m.Y,m.Yste)
else
    errorbar(m.X,m.Y,m.Yerr)
end

set(gca,'xscale',props.xscale);
set(gca,'yscale',props.yscale);

if(~isempty(props.xlim))
    xlim(props.xlim);
end
if(~isempty(props.ylim))
    ylim(props.ylim);
end

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

