function showTwoPointCorr(m,props)

hold on


pixelSize = 0.16 % :((((;

confidence = 0.05;

corrfun = m.corr;
r = m.r;
r_csr = m.rCSR;
csr = m.csr;


csr_sorted = sort(csr,1);
csr_count = size(csr_sorted,1);
margin = ceil(confidence*csr_count);

meanY = median(csr_sorted,1);

colors = hsv(4);
%colors = colors*0.75;
nnn = numel(get(gca,'Children'))

if (~isempty(csr_sorted))
errYbot = meanY - csr_sorted(end - margin + 1,:);
errYtop = csr_sorted(margin,:) - meanY;



%shadedErrorBar(r_csr(1:end),meanY,[-errYbot;-errYtop],'lineprops','k');


iii = floor(nnn/5)+1
shadedErrorBar(r_csr(1:end),meanY,[-errYbot;-errYtop],{'Color', colors(iii,:), 'LineWidth', 2},1);
end
%plot(r_csr*pixelSize, csr_sorted(margin,:),'r');
%plot(r_csr*pixelSize, csr_sorted(end-margin+1,:),'r');

plot(r, corrfun,'k-', 'LineWidth', 2);

%plot(r, corrfun,'Color', colors(iii,:), 'LineWidth', 2);

if false && (isfield(m, 'randomExample'))
    plot(r_csr, m.randomExample,'k-', 'LineWidth', 2);
end

plot([0, r_csr(end)],[1, 1], 'k--',  'LineWidth', 2);
 

set(gca,'LineWidth',2)
set(gca,'FontSize',22)
box on
xlabel('distance [\mum]')
ylabel('G_{11}')
%set(gca,'yscale','log')

xlim([0,20])
end