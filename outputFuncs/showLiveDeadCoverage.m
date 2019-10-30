function showLiveDeadCoverage(m, props)

a=0;

scatter(m.dataParameters.time, m.liveArea/m.totalArea,'go')
scatter(m.dataParameters.time, m.deadArea/m.totalArea,'ro')


set(gca,'yscale','log');

end