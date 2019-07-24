% draws a rectangle around index (row, col) in a binary matrix with side
% length len

% if mat is created using zeros(), send as input logical(zeros())

function mat = drawRect(mat, row, col, len)

rowMatSize = size(mat, 1);
colMatSize = size(mat, 2);

startRow = fix(row - len / 2);
endRow = fix(row + len / 2);

startCol = fix(col - len / 2);
endCol = fix(col + len / 2);

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
