function displayErrorBars(m, parameters)

props = parseParams(parameters);

if(isfield(m, 'Yste'))
    errorbar(m.X,m.Y,m.Yste)
else
    errorbar(m.X,m.Y,m.Yerr)
end

set(gca,'xscale',props.xscale);
set(gca,'yscale',props.yscale);
end

function props = parseParams(v)
% default:
props = struct(...
    'xscale','linear',...
    'yscale','linear' ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'xscale'))
        props.xscale = v{i+1};
    elseif (strcmp(v{i}, 'yscale'))
        props.yscale = v{i+1};
    end
end

end
