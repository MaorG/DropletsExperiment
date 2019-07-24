% this function takes the first argument vector values and replaced each
% with its corresponding position value in the vector of the second
% argument; negative values in the second argument are ignored and the
% original first argument values stay there
% useful for example for changing size of graph but leaving position intact
% e.g. set(gcf, 'OuterPosition', replacePositiveVals(get(gcf, 'OuterPosition'), [-1 -1 50 50]));
function srcVec = replacePositiveVals(srcVec, targVec)
    chngPos = find(targVec >= 0);
    srcVec(chngPos) = targVec(chngPos);
end
