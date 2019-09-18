function text = convStrings2cellForEval(strsCell)

% input: cell with strings that convert to something evaluatable
% e.g. {'[1 2]', '[3 4]'}

textBegin = '{';
textEnd = '}';
strsSep = ',';

inCellStrs = '';

for i = 1 : numel(strsCell)
    curStr = strsCell{i};
    
    inCellStrs = addtok(inCellStrs, curStr, strsSep);
end

text = [textBegin, inCellStrs, textEnd];

end
