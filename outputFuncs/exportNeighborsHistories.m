function exportNeighborsHistories(m, properties)
if (isempty(m))
    close gcf;
    return;
end
props = parseParams(properties);

canvas = m.windows{1};

for i = 1:numel(m.windows)
%     info = [num2str(i) ' (' num2str(m.x(i)) ', ' num2str(m.y(i)) ')']
%     position = [0,0];
%     m.windows{i} = insertText(m.windows{i},position,info,'TextColor','white','FontSize',18, 'BoxColor', 'black');
%     position = [size(m.windows{i},2),0];
%     m.windows{i} = insertText(m.windows{i},position,num2str(i),'TextColor','white','FontSize',18, 'BoxColor', 'black', 'AnchorPoint', 'RightTop');
end

for i = 2:min(props.maxLines,numel(m.windows))
    if (size(m.windows{i},2) >  size(canvas,2))
        margin = 255*ones(size(canvas,1), size(m.windows{i},2) -  size(canvas,2),3);
%        canvas = cat(2,canvas,margin);
        canvas = cat(2,margin,canvas);
    elseif (size(m.windows{i},2) <  size(canvas,2))
        margin = 255*ones(size(m.windows{i},1), - size(m.windows{i},2) + size(canvas,2),3);
        %m.windows{i} = cat(2,m.windows{i},margin);
        m.windows{i} = cat(2,margin,m.windows{i});
    end
    
    margin = 255*ones(4,size(canvas,2),3);
    canvas = cat(1,canvas, margin, m.windows{i});
    
    
end

a=0;
fns = fieldnames(m.dataParameters);
paramNames = []
for i = 1:numel(fns)
    param = m.dataParameters.(fns{i});
    if isnumeric(param)
        param = num2str(param);
    end
    paramNames = [paramNames ' ' param]
end



outName = [props.outName paramNames '.jpg']
if (isa(canvas, 'uint16'))
    imwrite(im2uint8(canvas), outName);
else
    if (size(canvas,1)>20000)
         imwrite(canvas, [outName,'.tif']);
        %imwrite(canvas(1:floor(end/2),:,:), [outName, '_1.jpg']);
        %imwrite(canvas((floor(end/2)+1):end,:,:), [outName, '_2.jpg']);
    else
        imwrite(canvas, outName);
    end
end

end


function props = parseParams(v)
% default:
props = struct(...
    'outName', 'histories', ...
    'maxLines', inf...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'outName'))
        props.outName = v{i+1};
    elseif (strcmp(v{i}, 'maxLines'))
        props.maxLines = v{i+1};
    end
end

end