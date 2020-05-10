function displayRGBMasks(m, parameters)

props = parseParams(parameters);

BG = m.(props.BG);
if ~isempty(props.range)
    mmax = max(BG(:));
    mmin = min(BG(:));
    BG = range(1) + uint8(double(props.range(2)-props.range(1))*double(BG-mmin)/double(mmax-mmin));
end

if size(BG,3) == 1
    BG = repmat(BG,[1,1,3]);
end
imshow(BG);
hold on;


pos = [0,150];
for i = 1:numel(props.masks)
    maskEntry = props.masks{i};
    color = maskEntry{2};
    maskName = maskEntry{1};
    mask = m.(maskName)>0;
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
    flatColor = uint8(repmat(reshape(color,[1,1,3]),[size(mask,1), size(mask,2), 1]));
  
    hm = imshow(flatColor);
    mask = 0.75*mask;
    
    set(hm, 'AlphaData', mask);
    
    if props.verbose
        text(pos(1),pos(2), [maskName, ': ',  num2str(sum(mask>0,'all')*0.16*0.16), ' um^2'], 'FontSize', 20, 'FontWeight', 'bold', 'Color', double(color)/255, 'Interpreter', 'none')
        pos(2) = pos(2) + 150;
    end
end
 set(gcf, 'Units', 'Inches', 'Position', [0, 0, 2, 2]);
%saveas(gcf,['C:\school\papers\microbiota\revision\manualInput\', 'img_', m.parameters.well, '.png']);
print(gcf,['C:\school\papers\microbiota\revision\manualInput\', 'img_', m.parameters.well, '.png'],'-dpng', '-r2970');
    
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
        props.perim = v{i+1};
    end
end

end

