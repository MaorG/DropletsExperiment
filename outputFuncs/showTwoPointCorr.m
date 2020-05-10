function showTwoPointCorr(m,props)




pixelSize = 0.16;

confidence = 0.05;

corrfun = m.corr;
r = m.r;
r_csr = m.rCSR;
csr = m.csr;


csr_sorted = sort(csr,1);
csr_count = size(csr_sorted,1);
margin = ceil(confidence*csr_count);

meanY = median(csr_sorted,1);
errYbot = meanY - csr_sorted(end - margin + 1,:);
errYtop = csr_sorted(margin,:) - meanY;


hold on
%shadedErrorBar(r_csr(1:end),meanY,[-errYbot;-errYtop],'lineprops','k');

colors = hsv(3);
nnn = numel(get(gca,'Children'))
if nnn == 0
    shadedErrorBar(r_csr(1:end),meanY,[-errYbot;-errYtop],{'Color', colors(1,:)},1);
elseif nnn == 5
    shadedErrorBar(r_csr(1:end),meanY,[-errYbot;-errYtop],{'Color', colors(2,:)},1);
elseif nnn == 10
    shadedErrorBar(r_csr(1:end),meanY,[-errYbot;-errYtop],{'Color', colors(3,:)},1);
end

%plot(r_csr*pixelSize, csr_sorted(margin,:),'r');
%plot(r_csr*pixelSize, csr_sorted(end-margin+1,:),'r');

 plot(r, corrfun,'k-', 'LineWidth', 2);

if false && (isfield(m, 'randomExample'))
    plot(r_csr, m.randomExample,'k-', 'LineWidth', 2);
end
 
 
xlim([0,25]);
set(gca,'LineWidth',2)
set(gca,'FontSize',14)
box on
xlabel('distance [\mum]')
ylabel('G_{11}')
%set(gca,'yscale','log')
end