function showKfunc(m,props)

totCounts = m.totCounts;
totAreas = m.totAreas;
rbins = m.rbins;
N = m.N;
validPixelCount = m.validPixelCount;

plot(rbins,mean(totCounts./totAreas),'b')
hold on


RN = 1000;
confint = 0.01;

%conftop = nan(size(expected));
%confbot = nan(size(expected));

%if false
    % poisson
    expected = N.*(sum(totAreas,1)./validPixelCount);
    conftop = nan(size(expected));
    confbot = nan(size(expected));
    for ei = 1:numel(expected)
        
        r = poissrnd(expected(ei),[RN,1]);
        rs = sort(r);
        conftop(ei) = rs(round(RN*(1-confint)));
        confbot(ei) = rs(round(RN*(confint)));
    end
    errorbar(rbins,expected./sum(totAreas),(expected-confbot)./sum(totAreas),(conftop-expected)./sum(totAreas),'r')
%else


    % binomial
    expected = N.*(sum(totAreas,1)./validPixelCount);

    conftop = nan(size(expected));
    confbot = nan(size(expected));

    p = sum(totAreas,1)./validPixelCount;
    
    for ei = 1:numel(expected)
        rs = nan(RN,1);
        for ri = 1:RN
            r = rand(N,1);
            hitCount = sum(p(ei)>r);
            rs(ri) = hitCount;
        end
        rs = sort(rs);
        conftop(ei) = rs(round(RN*(1-confint)));
        confbot(ei) = rs(round(RN*(confint)));
        errorbar(rbins,expected./sum(totAreas),(expected-confbot)./sum(totAreas),(conftop-expected)./sum(totAreas),'g')
    end
    
%end


%errorbar(rbins,expected,expected-confbot,conftop-expected)
%title([data.parameters.well, ' ', num2str(data.parameters.time)]);
%set(gca,'yscale','log');
%set(gca,'xscale','log');

end