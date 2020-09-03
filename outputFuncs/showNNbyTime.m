function showNNbyTime(m, properties)
props = parseParams(properties);

timepoints = cat(1,m{1}.time);

obsVals = cat(1, m{1}.obsQuantityAtDistance);
rndMat = cat(1,m{1}.rndQuantityAtDistance);
rndMatTotal = cat(1,m{1}.rndQuantityTotal);
if strcmp (props.norm,'fraction')
   obsVals = obsVals./ cat(1,m{1}.obsQuantityTotal);
   rndMat = rndMat ./ rndMatTotal;
end



rndMean = mean(rndMat,2)
confidence = props.confidence;

margin = ceil(confidence*size(rndMat,2));


rndMatSorted = sort(rndMat,2);
rndTop = (rndMatSorted(:,end-margin+1));
rndBot = (rndMatSorted(:,margin));


hold on;

plot(timepoints, obsVals,'k');
shadedErrorBar(timepoints, obsVals,[rndTop-obsVals, obsVals-rndBot],'k')


set(gca,'LineWidth',2)
set(gca,'FontSize',14)
box on

end

function props = parseParams(v)
% default:
props = struct(...
    'confidence', 0.05, ...
    'norm', 'none' ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'confidence'))
        props.confidence = v{i+1};
    elseif (strcmp(v{i}, 'norm'))
        props.norm = v{i+1};
    end
end

end
