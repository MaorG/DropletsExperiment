function validationCreateEntitiesByRandomizingRanges(data,parameters,resNames)


props = parseParams(parameters);

pixelSize = data.properties.pixelSize;

%imSize = data.properties.worldSize / (pixelSize^2);
ndrops = data.properties.dropNum;
dropSizeRange = data.properties.dropSizeRange;
%dropWidth = data.properties.dropWidth / (pixelSize^2);
%spaceBetweenDrops = data.properties.spaceBetweenDrops;
%dropSpaceFromTop = data.properties.dropSpaceFromTop;
%dropSpaceFromLeft = data.properties.dropSpaceFromLeft;

singCellSqSize = repmat(sqrt(data.properties.cellSize / (pixelSize^2)), 1, 2); % the size is in square pixels so we duplicate the squares to get the width+height measures
nRperDropRange = data.properties.RNumPerDropRange;
nGperDropRange = data.properties.GNumPerDropRange;
cellSpaceFromLeft = data.properties.cellSpaceFromLeft;
%cellSpaceFromTop = fix((dropWidth - singCellSqSize(1)) / 2); % place at center of droplet (row)
spaceBetweenCells = data.properties.spaceBetweenCells;



% imDrops = logical(zeros(imSize));
% imRCells = imDrops;
% imGCells = imDrops;

dropSizes = randomizeRange(dropSizeRange, ndrops, {'pixelSize' pixelSize});

cellsPerDrop = [];

% curRow = dropSpaceFromTop;
% rectStartCol = dropSpaceFromLeft;
for i = 1 : ndrops
%     rectStartRow = curRow;
    dropSize = dropSizes(i);
    
    maxCellsForDrop = getMaxCells(dropSize, cellSpaceFromLeft, singCellSqSize(2), spaceBetweenCells);
    
    nR = nRperDropRange;
    nG = nGperDropRange;

    nRcells = randomizeRange(nR, 1, {'maxNum' maxCellsForDrop});
    nGcells = randomizeRange(nG, 1, {'maxNum' maxCellsForDrop});
    
    %imDrops = drawRect(imDrops, rectStartRow, rectStartCol, dropSize, {'len2' dropWidth 'startingPoint' 'beginning'});

    cells = [repmat('R', 1, nRcells), repmat('G', 1, nGcells)];
    cells = cells(randperm(numel(cells)));
    if (numel(cells) > maxCellsForDrop)
        cells = cells(1:maxCellsForDrop);
    end
   
    if (isempty(cells))
        cells = 'N';
    end
    
    cellsPerDrop = addtok(cellsPerDrop, cells, ' ');
    
%     rectStartRowCells = rectStartRow + cellSpaceFromTop;
%     rectStartColCells = rectStartCol + cellSpaceFromLeft;
    
    % debugging:
    % fprintf('Droplet %d: %d R cells, %d G cells\n', i, nRcells, nGcells);
    
%     for x = 1 : numel(cells)
%         curCell = cells{x};
%         if (strcmp(curCell, 'R'))
%             imRCells = drawRect(imRCells, rectStartRowCells, rectStartColCells, singCellSqSize(2), {'len2' singCellSqSize(1) 'startingPoint' 'begining'});
%         elseif (strcmp(curCell, 'G'))
%             imGCells = drawRect(imGCells, rectStartRowCells, rectStartColCells, singCellSqSize(2), {'len2' singCellSqSize(1) 'startingPoint' 'begining'});
%         end
%         rectStartColCells = rectStartColCells + singCellSqSize(2) + spaceBetweenCells;
%         if ((rectStartColCells+singCellSqSize(2)) > (dropSpaceFromLeft + dropSize))
%             break;
%         end
%     end
%     
%     curRow = curRow + dropWidth + spaceBetweenDrops;
end

dropsPos = find(strcmp(props.srcOrder, 'drops'));
cellsPos = find(strcmp(props.srcOrder, 'cells'));

data.(resNames{dropsPos}) = dropSizes;
data.(resNames{cellsPos}) = cellsPerDrop;

% visualization
%imtool(cat(3, imRCells*255, imGCells*255, imDrops*255));





end


function cellNum = getMaxCells(dropSize, spaceOne, cellSize, spacing)

cellNum = fix((dropSize - spaceOne) / (cellSize + spacing));

end

function r = randomizeRange(range, n, parameters)
% randomize by range or by distribution: [N1 N2] for uniform range, {[x1 x2
% x3 x4 x5 ...], [y1 y2 y3 y4 y5 ...]} for random nubmer from distribution
% if maxNum is specified - each inf instance is replaced by that number
% (typically used when randomizing cell number and you want to use the
% maximum possible number of cells that can fit)
% n - number of random numbers to generate

props = parseParams2(parameters);

pixelSize = props.pixelSize;
maxNum = props.maxNum;

if (iscell(range))
    X = fix(range{1} / pixelSize);
    Y = fix(range{2} / pixelSize);
    r = randByDistrib(X, Y, n);
elseif (numel(range) == 2) % range from two values
    % if number of cells in range is specified as inf, change it to
    % the maximum number possible for that drop
    if (~isempty(maxNum))
        range(range == inf) = maxNum;
    end
    range = fix(range / pixelSize);
    if (diff(range) < 0)
        r = 0;
    else
        r = randi(range, 1, n);
    end
    
end
    
   

end

function props = parseParams(v)
% default:
props = struct(...
    'srcOrder',''...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'srcOrder'))
        props.srcOrder = v{i+1};     
    end
    
end

end

function props = parseParams2(v)
% default:
props = struct(...
    'pixelSize',1,...
    'maxNum',[]...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'pixelSize'))
        props.pixelSize = v{i+1};
    elseif (strcmp(v{i}, 'maxNum'))
        props.maxNum = v{i+1};
    end
    
end

end