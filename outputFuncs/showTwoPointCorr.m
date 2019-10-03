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


hold on
plot(r_csr*pixelSize, csr_sorted(margin,:),'r');
plot(r_csr*pixelSize, csr_sorted(end-margin+1,:),'r');

 plot(r*pixelSize, corrfun,'b');
 
 xlim([0,25]);
 

end