function displayScatterAndErrorBins(m, parameters)

    props = parseParams(parameters);
    
    x = m.(props.xname);
    y = m.(props.yname);
    bins = (props.bins);
    
    scatter(x,y);
    
    [Ni,~,binidx] = histcounts(x,bins);
    
    
    set(gca,'xscale','log')
    
    xlim([30,2e5])

end

function props = parseParams(v)
% default:
props = struct(...
    'xname', 'x', ...
    'yname', 'y', ...
    'bins', power(10,1:0.5:5) ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'xParam'))
        props.xParam = v{i+1};
    elseif (strcmp(v{i}, 'bins'))
        props.bins = v{i+1};
    end
end

end