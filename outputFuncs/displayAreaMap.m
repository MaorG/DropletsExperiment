function displayAreaMap(m, parameters)



props = parseParams(parameters);

seg = m.(props.seg);

map = zeros(size(seg));

s = regionprops(seg,'PixelIdxList', 'Area');

for i = 1:numel(s)
    map(s(i).PixelIdxList) = log10(s(i).Area);
end


if (props.ordered == 0)
    %imshow(imresize(map,0.13))
    imshow(map)
else
    omap = sort(map(:));
    omap = reshape(omap,size(map));
    imshow(imresize(omap,0.1))
end

caxis([1,7])
cmap = colormap('hsv');

cmap(1,:) = [0,0,0];
colormap(cmap);

colorbar

return;

channels = cell(0);
cindices = zeros(3,1);

if (~isempty(props.R))
    channels{1} = mat2gray(m.(props.R), props.Rscale);
    cindices(1) = 1;
end
if (~isempty(props.G))
    channels{2} = mat2gray(m.(props.G), props.Gscale);
    cindices(2) = 1;
end
if (~isempty(props.B))
    channels{3} = mat2gray(m.(props.B), props.Bscale);
    cindices(3) = 1;
end

for i = 1:3
    if isempty(channels{i})
        Isize = size(channels{find(cindices, 1 )});
        channels{i} = zeros(Isize);
    end
end

imshow(cat(3,channels{1},channels{2},channels{3}));

end

function props = parseParams(v)
% default:
props = struct(...
    'seg','DropMask',...
    'ordered','0'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'seg'))
        props.seg = v{i+1};
    elseif (strcmp(v{i}, 'ordered'))
        props.ordered = v{i+1};
    end
end

end

