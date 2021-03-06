function displaySigmoidFit(m, parameters)

    props = parseParams(parameters);
    
    x = m.(props.xname);
    y = m.(props.yname);
    
    x = log10(x);
    y = y > 0.01;
    
    h = scatter(x,y);
    color = h.CData

   
    logisticEqn = '1/(1+(exp(-1*(a+b*x))))'
    f1 = fit(x, y, logisticEqn)
    
    xq = 1.5:0.01:5.5;
    yq = f1(xq);
    plot(xq,yq,'Color', color);
    plot(-1*[f1.a/f1.b,f1.a/f1.b],[0,1],'Color', color);
    

    
    
    %set(gca,'xscale','log')
    
    xlim([1.5,5.5])

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