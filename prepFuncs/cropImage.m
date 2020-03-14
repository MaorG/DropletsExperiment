function [res] = cropImage(data, parameters)

props = parseParams(parameters);



I = data.(props.src);

borders = data.properties.(props.borders);
% top = data.properties.(props.borders{1});
% bottom = data.properties.(props.borders{2});
% left = data.properties.(props.borders{3});
% right = data.properties.(props.borders{4});

if numel(borders) == 4
    top = borders{1};
    bottom = borders{2};
    left = borders{3};
    right = borders{4};

    if ~isempty(bottom)
        I = I(1:bottom,:,:);
    end
    if ~isempty(top)
        I = I(top:end,:,:);
    end
    if ~isempty(right)
        I = I(:,1:right,:);
    end
    if ~isempty(left)
        I = I(:,left:end,:);
    end

end

res = I;


end

function props = parseParams(v)
% default:
props = struct(...
    'src','GFP'...
    );

props.borders = {'top' 'bottom' 'left' 'right'};

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'borders'))
        props.borders = v{i+1};
    end
end

end