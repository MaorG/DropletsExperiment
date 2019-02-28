function members = assignMembers(entities, data, parameters)

props = parseParams(parameters);

parents = entities{1};
children = entities{2};

parentsMap = parents.props.seg;
childrenMap = children.props.seg;

% TODO - don't use an seg, it may be outdated, create from entities
%      - or perhaps make a func to update seg

CCp = bwconncomp(parentsMap);
Lp = labelmatrix(CCp);
CCc = bwconncomp(childrenMap);
Lc = labelmatrix(CCc);

Lpairs = cat(2,Lp(:),Lc(:));
idx = find(Lpairs(:,1) & Lpairs(:,2));

PairIndices = unique(cat(2,Lp(idx),Lc(idx)),'rows');

if (props.verbose)
    figure;
    imshow(0.99*cat(3,parents.props.seg,children.props.seg,0*parents.props.seg));
    for i = 1:size(PairIndices,1)
        pIdx = PairIndices(i,1);
        cIdx = PairIndices(i,2);
        x1 = parents.props.regions(pIdx).Centroid(1);
        y1 = parents.props.regions(pIdx).Centroid(2);
        x2 = children.props.regions(cIdx).Centroid(1);
        y2 = children.props.regions(cIdx).Centroid(2);
        line([x1,x2],[y1,y2],'Color','blue');
    end
end

members = cell(size(parents.props.regions));
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
