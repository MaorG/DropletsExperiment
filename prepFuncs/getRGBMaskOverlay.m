function RGB = getRGBMaskOverlay(data, parameters)

props = parseParams(parameters);

BG = data.(props.BG);
if ~isempty(props.range)
    mmax = max(BG(:));
    mmin = min(BG(:));
    BG = range(1) + uint8(double(props.range(2)-props.range(1))*double(BG-mmin)/double(mmax-mmin));
end

if size(BG,3) == 1
    BG = repmat(BG,[1,1,3]);
end
RGB = BG;

pos = [0,150];
for i = 1:numel(props.masks)
    maskEntry = props.masks{i};
    color = maskEntry{2};
    maskName = maskEntry{1};
    mask = data.(maskName)>0;
    if (props.perim > 0)
        maskPerim = bwperim(mask);
        if props.perim > 1
            disk = fspecial('disk', props.perim-1);
            SE = strel('disk',props.perim-1);
            maskPerim = imdilate(maskPerim, SE);
            maskPerim = maskPerim & mask;
        end
        mask = maskPerim;
    end
  
    RGB(:,:,1) = uint8(0.5*RGB(:,:,1) + 0.5*( RGB(:,:,1) .* uint8(~mask) + color(1)*uint8(mask)));
    RGB(:,:,2) = uint8(0.5*RGB(:,:,2) + 0.5*( RGB(:,:,2) .* uint8(~mask) + color(2)*uint8(mask)));
    RGB(:,:,3) = uint8(0.5*RGB(:,:,3) + 0.5*( RGB(:,:,3) .* uint8(~mask) + color(3)*uint8(mask)));
    
end
    
end
    
function props = parseParams(v)
% default:
props = struct(...
    'BG','RGB',...
    'verbose', 0, ...
    'perim', 0 ... % 0: solid, >0: line width
    );

props.range = [];
props.masks = {};

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'BG'))
        props.BG = v{i+1};
    elseif (strcmp(v{i}, 'range'))
        props.range = v{i+1};
    elseif (strcmp(v{i}, 'masks'))
        props.masks = v{i+1};
    elseif (strcmp(v{i}, 'perim'))
        props.perim = v{i+1};
    elseif (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};
    end
end

end

