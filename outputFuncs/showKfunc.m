function showKfunc(m,props)

props = parseParams(props);

expK = m.rk;
rndK = m.rkrnds;
bins = m.bins;
confidence = props.confidence;

pixelSize = 0.16;

margin = ceil(props.confidence*size(rndK,1));

sortedY = sort(rndK,1);

meanY = median(sortedY,1);
errYbot = meanY - sortedY(end - margin + 1,:);
errYtop = sortedY(margin,:) - meanY;

hold on;

shadedErrorBar(bins(1:end)*pixelSize,meanY,[-errYbot;-errYtop],'lineprops','k--');

plot(bins(1:end)*pixelSize, expK,'k-', 'LineWidth', 2);

set(gca,'LineWidth',2)
set(gca,'FontSize',14)
box on
xlabel('distance [\mum]')
ylabel('k')

xlim([0,100])

end


function props = parseParams(v)
% default:
props = struct(...
    'confidence', 0.05, ...
    'showAll', 0 ...
);

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'confidence'))
        props.confidence = v{i+1};
    elseif (strcmp(v{i}, 'showAll'))
        props.showAll = v{i+1};
    end
end

end



function idontknow
%%% ? ? ? ? ? ? 
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