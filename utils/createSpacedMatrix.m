function medges = createSpacedMatrix(edges, option, betweenPairsStr)
% INPUT example: [0 1 2 4 8 16]
% option - optional, if set to 'range', each entry of the output is a range
% of two consecutive values
% if option is 'range' and edges is two rows it
% is used thus: createSpacedMatrix([10 10 10 10 10; 0 1 2 3 4],
% 'rangeTwoRows', '^') will return ['10^0'; '10^1'; '10^2'; '10^3'; '10^4']
% betweenPairsStr - optional, may be used when option = 'range' is used,
% default is '-'
% OUTPUT example for range: ['0-1 '; '1-2 '; '2-4 '; '4-8 '; '8-16']

% separator when 'range' option is used:
if (~exist('betweenPairsStr', 'var'))
    betweenPairsStr = '-';
end

% separate numbers in edges to cells
%cedges = compose('%d', edges); % bad functionality with floating points
cedges = cell(0);
for i = 1 : size(edges,1) % iterate rows
    cedges = [cedges; strsplit(num2str(edges(i, :)), ' ')];
end        
cedges2 = []; % will be used when there are two rows

rangeIteratorSubtract = 1;

% edgesLens = intLen(edges); % bad functionality with floating points
edgesLens = cellfun(@numel, cedges);
[maxLen, maxLenInd] = max(edgesLens(1, :)); % find length and index of the value with the biggest length
if (size(edgesLens, 1) > 1)
    nextMaxLen = max(edgesLens(2, :));
    cedges2 = cedges(2, :);
    cedges = cedges(1, :);
    rangeIteratorSubtract = 0;
else
    edgesLens2 = edgesLens;
    edgesLens2(maxLenInd) = [];
    nextMaxLen = max(edgesLens2); % find next largest
end


if (exist('option', 'var') && any(strcmp(option, 'range')))
    ranged = true;
    totMaxLen = maxLen + length(betweenPairsStr) + nextMaxLen;
    iterateTo = numel(cedges) - rangeIteratorSubtract;
else
    ranged = false;
    totMaxLen = maxLen;
    iterateTo = numel(cedges);
end


medges = char;
 
for i = 1 : iterateTo
   if (ranged)
       if (isempty(cedges2))
           secElement = cedges{i + 1};
       else
           secElement = cedges2{i};
       end
       if (i == 20)
           disp(i)
       end
       medges(i, :) = centerSpacedText([cedges{i}, betweenPairsStr, secElement], totMaxLen, 'fullLength');
   else
       medges(i, :) = centerSpacedText(cedges{i}, totMaxLen, 'fullLength');
   end
end


end