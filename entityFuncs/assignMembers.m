function members = assignMembers(entities, data, parameters)

props = parseParams(parameters);

parents = entities{1};
children = entities{2};

parentsMap = parents.seg>0;
childrenMap = children.seg>0;

% TODO - don't use an seg, it may be outdated, create from entities
%      - or perhaps make a func to update seg

CCp = bwconncomp(parentsMap);
Lp = uint16(labelmatrix(CCp));
CCc = bwconncomp(childrenMap);
Lc = uint16(labelmatrix(CCc));

Lpairs = cat(2,Lp(:),Lc(:));
idx = find(Lpairs(:,1) & Lpairs(:,2));

PairIndices = unique(cat(2,Lp(idx),Lc(idx)),'rows');

if (props.verbose)
    figure;
    imshow(0.99*cat(3,parentsMap,childrenMap,0*parents.seg));
    for i = 1:size(PairIndices,1)
        pIdx = PairIndices(i,1);
        cIdx = PairIndices(i,2);
        x1 = parents.regions(pIdx).Centroid(1);
        y1 = parents.regions(pIdx).Centroid(2);
        x2 = children.regions(cIdx).Centroid(1);
        y2 = children.regions(cIdx).Centroid(2);
        line([x1,x2],[y1,y2],'Color','blue');
    end
end

members = cell(size(parents.regions));
for i = 1:size(PairIndices,1)
    pIdx = PairIndices(i,1);
    cIdx = PairIndices(i,2);
    members{pIdx} = [members{pIdx}, cIdx];
end

end

function props = parseParams(v)
% default:
props = struct(...
    'verbose',0 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};
    end
end

end
