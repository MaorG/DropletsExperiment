function plot_live_dead_bars(m, properties)

X = m.X;
YR = m.YR;
YG = m.YG;

hb = bar(log10(X),[YG;YR]','stacked','LineWidth',2)
hb(1).FaceColor = 'g';
hb(2).FaceColor = 'r';
% set(gca,'XTick',log(X));
% set(gca,'XTickLabel',{num2str(X)});
%xlabel('drop area');
%ylabel('pop area');


% plot beautification
axes1 = gca
%ylabel({'Total area covered';' by cells [\mum^2] per [mm^2]'},'FontWeight','bold');
% Create xlabel
%xlabel('log_{10}(droplet area [\mum^2])','FontWeight','bold');
% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes1,[1.65 5.35]);
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'FontSize',15,'FontWeight','bold','LineWidth',2,'XTick',...
    [1.25,1.75 2.25 2.75 3.25 3.75 4.25 4.75],'XTickLabel',...
    {'1.5','2','2.5','3','3.5','4','4.5','5'},'YGrid','on');
xlim([0.85,4.55])
ylim([0,7e3])

% saveas(gcf,'figures v4 alt bins/a506 bars.fig')
% print('figures v4 alt bins/a506 bars','-dtiff','-r300')
% or:
% saveas(gcf,'figures v4 alt bins/kt bars.fig')
% print('figures v4 alt bins/kt bars','-dtiff','-r300')

end
