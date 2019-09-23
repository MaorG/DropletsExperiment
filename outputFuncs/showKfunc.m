function showKfunc(m,props)

totCounts = m.totCounts;
totAreas = m.totAreas;
rbins = m.rbins;
N = m.N;
validPixelCount = m.validPixelCount;

plot(rbins,mean(totCounts))
hold on

expected = N.*(mean(totAreas,1)./validPixelCount);

RN = 1000;
confint = 0.01;

conftop = nan(size(expected));
confbot = nan(size(expected));

for ei = 1:numel(expected)
    r = poissrnd(expected(ei),RN);
    rs = sort(r);
    conftop(ei) = rs(round(RN*(1-confint)));
    confbot(ei) = rs(round(RN*(confint)));
end



errorbar(rbins,expected,expected-confbot,conftop-expected)
%title([data.parameters.well, ' ', num2str(data.parameters.time)]);
set(gca,'yscale','log');
set(gca,'xscale','log');

end