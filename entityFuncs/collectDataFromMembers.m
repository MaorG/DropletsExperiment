function [res] = collectDataFromMembers(entities, data, parameters)
% collectDataFromMembers 
% get information from 

props = parseParams(parameters);

hosts = entities{1};
members = entities{2};

memberIndices = hosts.(props.members);
memberParameters = members.(props.parameters);

res = zeros(size(memberIndices,1),size(memberParameters,2));
for hi = 1:numel(memberIndices)
    temp = zeros(1,size(memberParameters,2));
    membersIndicesInHost = memberIndices{hi};
    for mi = membersIndicesInHost
        temp = temp + memberParameters(mi,:);
    end
    res(hi,:) = temp;
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

