function displayBioRepBoxPlot(m, parameters)

    props = parseParams(parameters);


%    scatter3(m(:,1),m(:,2),m(:,3),'r')
%     set(gca,'yscale','log');
%     set(gca,'xscale','log');
%     view([1,0,1])

    cellbin = [1, 2];
    idx = find(m(:,1) > cellbin(1) & m(:,1) < cellbin(2)); 
    a1 = m(idx,1);
    a2 = m(idx,2);
    a3 = m(idx,3);
    %scatter3(em.am.IvAvDA.T{i}{1}(idx,1),em.am.IvAvDA.T{i}{1}(idx,2),em.am.IvAvDA.T{i}{1}(idx,3))
    %set(gca,'yscale','log');

    dropbins = props.dropBins;
    [N,edges,bin] = histcounts(a2,dropbins);
    
    boxplot(a3,bin,'Labels',(dropbins(bin+1)));
    hold on
    scatter(bin,a3,10*power(a1,0.5))
    
%     scatter3(a1,a2,a3,'r')
%     set(gca,'yscale','log');
%     set(gca,'xscale','log');
%     view([1,1,1])
%     xlabel('cell')
%     ylabel('drop')
    
end

function props = parseParams(v)
% default:
props = struct(...
    'dropBins',[0,30,10000,inf] ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'dropBins'))
        props.dropBins = v{i+1};
    end
end

end


