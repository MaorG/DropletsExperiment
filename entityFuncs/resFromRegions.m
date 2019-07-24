function [res] = resFromRegions(entities, data, parameters)

props = parseParams(parameters);

if isempty(entities.regions)
    res = [];
    return
end

% generate a cell array
ca = struct2cell(entities.regions);
fns = fieldnames(entities.regions);

%% the hard way
% for i = 1:numel(fns)
%     if strcmpi(fns(i), props.regionProp) 
%         res = ca(i,:);
%         try
%            res = cell2mat(res);
%            res = reshape(res,numel(entities.regions),numel(res)/numel(entities.regions));
%         catch exception
%            if (strcmp(exception.identifier,'MATLAB:catenate:dimensionMismatch'))
%                 disp(exception)
%            end
%         end       
%     end
% end

%% the practical way
for i = 1:numel(fns)
    if strcmpi(fns(i), props.regionProp) 
        res = ca(i,:);
        if (~  strcmpi(fns(i), 'PixelIdxList') && ~strcmpi(fns(i), 'Centroid') )
           res = cell2mat(res);
           res = reshape(res,numel(entities.regions),numel(res)/numel(entities.regions));
        else
            
        end       
    end
end



end


function props = parseParams(v)
% default:
props = struct(...
    'regionProp','Area'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'regionProp'))
        props.regionProp = v{i+1};
    end
end

end

