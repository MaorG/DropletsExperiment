function res = classifyFluorescenceByMasks(data,parameters)

props = parseParams(parameters);

src1 = data.(props.src1);
src2 = data.(props.src2);
ch1 = data.(props.ch1);
ch2 = data.(props.ch2);

idx1 = find((src1(:) > 0) & (src2(:) == 0));
idx2 = find((src2(:) > 0) & (src1(:) == 0));
idx12 = find((src1(:) > 0) & (src2(:) > 0));

idxAll = [idx1; idx2; idx12];

sampleSize1 = ceil(max(1000,numel(idx1)/100));
sampleSize2 = ceil(max(1000,numel(idx2)/100));

idx1f = randsample(idx1,sampleSize1);
idx2f = randsample(idx2,sampleSize2);



group1 = [ch1(idx1f),ch2(idx1f)];
group2 = [ch1(idx2f),ch2(idx2f)];

groups = [group1;group2];
classes = [ones(numel((idx1f)),1); 2*ones(numel((idx2f)),1)];



cl = fitcsvm(double(groups),classes,'KernelFunction','linear',...
    'BoxConstraint',Inf,'ClassNames',[1,2]);

labels = predict(cl,double([ch1(idxAll),ch2(idxAll)]) );

labels1 = find(labels == 1);
labels2 = find(labels == 2);

labelMap = zeros(size(ch1));
labelMap(idxAll(labels1)) = 1;
labelMap(idxAll(labels2)) = 2;


if props.verbose
    figure;
    hold on;
    scatter(ch1(idx1),ch2(idx1),'r+');
    scatter(ch1(idx2),ch2(idx2),'gx');
    scatter(ch1(idxAll(labels1)),ch2(idxAll(labels1)),'r.');
    scatter(ch1(idxAll(labels2)),ch2(idxAll(labels2)),'g.');
    
    figure;
    labelMap = zeros(size(ch1));
    labelMap(idxAll(labels1)) = 1;
    labelMap(idxAll(labels2)) = 2;
    imshow(double(cat(3,labelMap == 2, labelMap == 1, labelMap == 0)));
end

res = labelMap;

end

function props = parseParams(v)
% default:
props = struct(...
    'src1','CellMask1',...
    'ch1','GFP',...
    'src2','CellMask2',...
    'ch2','MCH',...
    'verbose', 0 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src1'))
        props.src1 = v{i+1};
    elseif (strcmp(v{i}, 'ch1'))
        props.ch1 = v{i+1};
    elseif (strcmp(v{i}, 'src2'))
        props.src2 = v{i+1};
    elseif (strcmp(v{i}, 'ch2'))
        props.ch2 = v{i+1};
    elseif (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};
    end
end

end
