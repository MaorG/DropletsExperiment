function [res] = collectDataFromMembers(entities, data, parameters)
% collectDataFromMembers 
% get information from 

props = parseParams(parameters);

hosts = entities{1};
members = entities{2};

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
    'parameters','liveDeadPixelCount' ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'members'))
        props.seg = v{i+1};
    elseif (strcmp(v{i}, 'parameters'))
        props.parameters = v{i+1};
    end
end

end

