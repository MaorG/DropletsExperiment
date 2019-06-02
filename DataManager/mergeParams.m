function params1  = mergeParams(params1, params2)

% params1 - the default parameters
% params2 - new parameters to change (existing) or add to the default
% parameters

propNames2 = {params2{1:2:end}};

for i = 1 : 2 : numel(params1)
    propName1 = params1{i};
    propNames2Pos = find(strcmp(propName1, propNames2)); % positions of current params1 property in params2 props
    if (~isempty(propNames2Pos))
        propNames2PosOrig = propNames2Pos * 2 - 1; % original positions in params2
        for x = 1 : numel(propNames2PosOrig)
            propValue2 = params2{propNames2PosOrig(x) + 1};
            params1{i + 1} = propValue2;
        end
        propNames2(propNames2Pos) = [];
        params2(merge2vecsAlternat(propNames2PosOrig, propNames2PosOrig + 1)) = [];
    end
        
end

params1 = [params1, params2];

end
