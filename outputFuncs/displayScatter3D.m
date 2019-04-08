function displayScatter3D(m, properties)

%    scatter3(m(:,1),m(:,2),m(:,3),'r')
%     set(gca,'yscale','log');
%     set(gca,'xscale','log');
%     view([1,0,1])

    
    cellbin = [0.5, 3];
    idx = find(m(:,1) > cellbin(1) & m(:,1) < cellbin(2)); 
    a1 = m(idx,1);
    a2 = m(idx,2);
    a3 = m(idx,3);
    %scatter3(em.am.IvAvDA.T{i}{1}(idx,1),em.am.IvAvDA.T{i}{1}(idx,2),em.am.IvAvDA.T{i}{1}(idx,3))
    %set(gca,'yscale','log');

    dropbins = [1,power(10, 1.5:0.5:6)];
    [N,edges,bin] = histcounts(a2,dropbins);
    
    boxplot(a3,bin,'Labels',log10(dropbins(bin+1)));
    
    
    
end