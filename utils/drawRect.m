% draws a rectangle around index (row, col) in a binary matrix with column
% length len (width) and row length of prop 'len2' (height); if len2 is left out,
% draws a square

% example: mat = drawRect(mat, row, col, 10, {'len2' 20 'startingPoint'
% 'beginning'});

% if mat is created using zeros(), send as input logical(zeros())


function mat = drawRect(mat, row, col, len, opts)


if (~exist('opts', 'var'))
    opts = {};
end
    
props = parseParams(opts);

len2 = props.len2;
if isempty(len2)
    len2 = len;
end
  
rowMatSize = size(mat, 1);
colMatSize = size(mat, 2);

if (strcmp(props.startingPoint, 'middle'))
    startRow = fix(row - len / 2);
    endRow = fix(row + len / 2);
    
    startCol = fix(col - len / 2);
    endCol = fix(col + len / 2);
else
    startRow = row;
    endRow = row + len2 - 1;
    
    startCol = col;
    endCol = col + len - 1;
end
    
    
if (startRow < 1)
    startRow = 1;
end
if (endRow > rowMatSize)
    endRow = rowMatSize;
end
if (startCol < 1);
    startCol = 1;
end
if (endCol > colMatSize)
    endCol = colMatSize;
end

mat(startRow:endRow, startCol:endCol) = 1;

end


function props = parseParams(v)
% default:
props = struct(...
    'len2',[],...
    'startingPoint','middle'... % by default the rectangle is drawn around the index ('middle'); if this option is set to 'beginning', the drawing starts exacly at row,col
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'len2'))
        props.len2 = v{i+1};
    elseif (strcmp(v{i}, 'startingPoint'))
        props.startingPoint = v{i+1};
    end
end

end