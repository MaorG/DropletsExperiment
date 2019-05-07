function doFormat


axes1 = gca;
set(axes1,'FontSize',24,'FontWeight','bold','LineWidth',2,'TickLength',...
    [0.02 0.05],'XMinorTick','on', 'YMinorTick','on');
box on


end

function extra

set(axes1,...
    'XTick',[100 1000 10000 100000],  ...
    'XTickLabel',{'10^2','10^3','10^4','10^5'},  ...
    'YTick',[0.1 1 10 100 1000],  ...
    'YTickLabel',{'10^-1','10^0','10^1','10^2','10^3'}  ...
    );


ylabel('Droplet density [mm^{-2}]');
xlabel('Droplet area [\mum^2]');

end