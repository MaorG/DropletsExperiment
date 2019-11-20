function showTwoPointCorr(m,props)

pixelSize = 0.16;

confidence = 0.01;

corrfun = m.corr;
r = m.r
r_csr = m.rCSR;
csr = m.csr;


csr_sorted = sort(csr,1);
csr_count = size(csr_sorted,1);
margin = ceil(confidence*csr_count);

meanY = median(csr_sorted,1);
errYbot = meanY - csr_sorted(end - margin + 1,:);
errYtop = csr_sorted(margin,:) - meanY;


hold on
shadedErrorBar(r_csr(1:end)*pixelSize,meanY,[-errYbot;-errYtop],'lineprops','k--');

%plot(r_csr*pixelSize, csr_sorted(margin,:),'r');
%plot(r_csr*pixelSize, csr_sorted(end-margin+1,:),'r');

 plot(r*pixelSize, corrfun,'k-', 'LineWidth', 2);

if false && (isfield(m, 'randomExample'))
    plot(r_csr*pixelSize, m.randomExample,'k-', 'LineWidth', 2);
end
 
 
xlim([0,100]);
set(gca,'LineWidth',2)
set(gca,'FontSize',14)
box on
xlabel('distance [\mum]')
ylabel('G_{11}')
%set(gca,'yscale','log')
end