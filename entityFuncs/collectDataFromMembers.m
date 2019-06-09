function [res] = collectDataFromMembers(entities, data, parameters, entitiesManager)
% collectDataFromMembers 
% get information from 

props = parseParams(parameters);

hosts = entities;
members = entitiesManager.getEntitiesByDataUID((props.targetEntities), entities.uniqueID);

memberIndices = hosts.(props.members);
memberParameters = members.(props.parameters);

res = cell(size(memberIndices,1),1); % result for all hosts: cell vector H-by-1
for hi = 1:numel(memberIndices)
    temp = zeros(numel(memberIndices{hi}),size(memberParameters,2));
    membersIndicesInHost = memberIndices{hi};
    for mi = 1:numel(membersIndicesInHost)
        midx = membersIndicesInHost(mi);
        temp(mi,:) = memberParameters(midx,:);
    end
    res{hi} = temp;
end

end


function props = parseParams(v)
% default:
props = struct(...
    'members','cells', ...
    'targetEntities','cells', ...
    'parameters','liveDeadPixelCount' ...
    );

targetEntitiesDefined = 0;

for i = 1:numel(v)
    if (strcmp(v{i}, 'members'))
        props.members = v{i+1};
    elseif (strcmp(v{i}, 'targetEntities'))
        targetEntitiesDefined = 1;
        props.targetEntities = v{i+1};
    elseif (strcmp(v{i}, 'parameters'))
        props.parameters = v{i+1};
    end
end

if ~targetEntitiesDefined
    props.targetEntities = props.members;
end 

end

