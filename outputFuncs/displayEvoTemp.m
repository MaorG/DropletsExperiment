function displayEvoTemp(m, parameters)

props = parseParams(parameters);


if isempty(m)
    return
end

cmap = [colormap('autumn'); flip(colormap('summer'),1)];
colormap(cmap);
hold on;

%filter out
% midx = find(m(:,2,2));
% m = m(midx,:,:);

if (props.plottype == 1)
    %caxis([0,1]);
    dims = size(m);
    
    hold on;
    for ci = 1:dims(1)
        
        
        
        x = [m(ci,1,1), m(ci,1,2)];
        y = [m(ci,2,1), m(ci,2,2)];
        z = [1,2];
        col = [m(ci,3,1), m(ci,3,2)];
        %col = log10([m(ci,1,1), m(ci,1,1)]);
        
        idx = find(m(ci,1,1) > 10)
        x = x(idx,:);
        y = y(idx,:);
        z = z(idx,:);
        col = col(idx,:);
        
        surface([x;x],[y;y],[z;z],[col;col],...
            'facecol','no',...
            'edgecol','interp',...
            'linew',1);
        scatter3(x(:,1),y(:,1),z(:,1),30,col(:,1), 'filled');
    end
    set(gca,'xscale','log')
    set(gca,'yscale','log')
    view([-1,-1,1]);
    view([0,0,1]);
else
    maxr = 1000;
    minr = 1/maxr;
    %caxis(log10([minr,maxr]));
    
    
    dims = size(m);
    
    clamp = @(x, min_val, max_val) (max(min_val,min(max_val,x)));
    
    
    x = m(:,1,1);
    y = max(log10(minr), min(log10(maxr), log10( m(:,2,2) ./ m(:,2,1) )));
    col = max(log10(minr), min(log10(maxr), log10( m(:,3,2) ./ m(:,3,1) )));

    x = max(log10(minr), min(log10(maxr), log10( m(:,1,2) ./ m(:,1,1) )));
    y = max(log10(minr), min(log10(maxr), log10( m(:,2,2) ./ m(:,2,1) )));
    col =   m(:,1,1);

   
    scatter(x,y,50,col,'filled')
    hold on
    plot([log10(minr), log10(maxr)], [0,0],'k');
    plot([0,0], [log10(minr), log10(maxr)],'k');
    
    xlim([log10(minr), log10(maxr)]);
    %xlim([-0.5,0.5]);
    ylim([log10(minr), log10(maxr)]);
    
    box on;
    colorbar
    
    %set(gca,'xscale','log')
    %set(gca,'yscale','log')
    %view([-1,-1,1]);
end
end

function props = parseParams(v)
% default:
props = struct(...
    'plottype',1 ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'plottype'))
        props.plottype = v{i+1};
    end
end

end
