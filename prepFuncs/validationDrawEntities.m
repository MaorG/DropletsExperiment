function validationDrawEntities(data,parameters,resNames)

props = parseParams(parameters);

pixelSize = data.properties.pixelSize;

imSize = fix(data.properties.worldSize / pixelSize);
dropWidth = fix(data.properties.dropWidth / pixelSize);
spaceBetweenDrops = data.properties.spaceBetweenDrops;
dropSpaceFromTop = data.properties.dropSpaceFromTop;
dropSpaceFromLeft = data.properties.dropSpaceFromLeft;
singCellSqSize = fix(repmat(sqrt(data.properties.cellSize / (pixelSize^2)), 1, 2)); % the size is in square pixels so we duplicate the squares to get the width+height measures
cellSpaceFromLeft = data.properties.cellSpaceFromLeft;
cellSpaceFromTop = fix((dropWidth - singCellSqSize(1)) / 2); % place at center of droplet (row)
spaceBetweenCells = data.properties.spaceBetweenCells;


dropsSrc = props.dropsSrc;
cellsSrc = props.cellsSrc;

if (isprop(data, dropsSrc))
    dropSizes = data.(dropsSrc);
elseif (isfield(data.properties, dropsSrc))
    dropSizes = data.properties.(dropsSrc);
else
    error('drops not found'); 
end

if (isprop(data, cellsSrc))
    cellsPerDrop = data.(cellsSrc);
elseif (isfield(data.properties, cellsSrc))
    cellsPerDrop = data.properties.(cellsSrc);
else
    error('cells not found'); 
end
cellsPerDrop = strsplit(cellsPerDrop, ' ');



imDrops = logical(zeros(imSize));
imRCells = imDrops;
imGCells = imDrops;


curRow = dropSpaceFromTop;
rectStartCol = dropSpaceFromLeft;

for i = 1 : numel(dropSizes)
  
    rectStartRow = curRow;
    dropSize = dropSizes(i);
    curCells = cellsPerDrop{i};
    
    imDrops = drawRect(imDrops, rectStartRow, rectStartCol, dropSize, {'len2' dropWidth 'startingPoint' 'beginning'});
    
    
    rectStartRowCells = rectStartRow + cellSpaceFromTop;
    rectStartColCells = rectStartCol + cellSpaceFromLeft;
    
    % debugging:
    % fprintf('Droplet %d: %d R cells, %d G cells\n', i, numel(strfind(cells,'R')), numel(strfind(cells,'G')));
    
    for x = 1 : numel(curCells)
        curCell = curCells(x);
        if (strcmp(curCell, 'R'))
            imRCells = drawRect(imRCells, rectStartRowCells, rectStartColCells, singCellSqSize(2), {'len2' singCellSqSize(1) 'startingPoint' 'begining'});
        elseif (strcmp(curCell, 'G'))
            imGCells = drawRect(imGCells, rectStartRowCells, rectStartColCells, singCellSqSize(2), {'len2' singCellSqSize(1) 'startingPoint' 'begining'});
        end
        
        rectStartColCells = rectStartColCells + singCellSqSize(2) + spaceBetweenCells;
    end
    
    curRow = curRow + dropWidth + spaceBetweenDrops;
end
    


dropsPos = find(strcmp(props.srcOrder, 'drops'));
GPos = find(strcmp(props.srcOrder, 'G'));
RPos = find(strcmp(props.srcOrder, 'R'));
dropsTarget = resNames{dropsPos};
GTarget = resNames{GPos};
RTarget = resNames{RPos};

data.(dropsTarget) = imDrops;
data.(GTarget) = imGCells;
data.(RTarget) = imRCells;


% visualization
imtool(cat(3, imRCells*255, imGCells*255, imDrops*255));


end





function props = parseParams(v)
% default:
props = struct(...
    'srcOrder','',...
    'dropsSrc','dropSizes',...
    'cellsSrc','cellsPerDrop'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'srcOrder'))
        props.srcOrder = v{i+1};     
    elseif (strcmp(v{i}, 'dropsSrc'))
        props.dropsSrc = v{i+1};     
    elseif (strcmp(v{i}, 'cellsSrc'))
        props.cellsSrc = v{i+1};             
    end
    
end

end